import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

import '../protocol/robot_protocol.dart';

class RobotController extends ChangeNotifier {
  // Inicializa Bluetooth cuando se solicita buscar o conectar.
  // Initializes Bluetooth when scanning or connecting is requested.
  late final _ble = FlutterReactiveBle();
  // Android devuelve UUID de 128 bits; Uuid compara los bytes sin expandirlos.
  // Android returns 128-bit UUIDs; Uuid compares bytes without expanding them.
  static final _service = Uuid.parse('fff0').expanded;
  static final _command = Uuid.parse('fff1').expanded;
  static final _status = Uuid.parse('fff2').expanded;
  final devices = <DiscoveredDevice>[];
  final _buttons = <int>{};
  StreamSubscription<DiscoveredDevice>? _scan;
  StreamSubscription<ConnectionStateUpdate>? _connection;
  StreamSubscription<List<int>>? _notifications;
  Timer? _scanTimeout;
  Timer? _heartbeat;
  QualifiedCharacteristic? _writer;
  bool _writing = false;
  bool _pending = false;
  bool _disposed = false;
  int _session = 0;
  int _searchSession = 0;

  bool scanning = false;
  bool connecting = false;
  bool connected = false;
  String? deviceName;
  String? error;
  RobotStatus status = const RobotStatus();
  int get buttons => RobotProtocol.command(_buttons);

  void _update() {
    if (!_disposed) notifyListeners();
  }

  Future<bool> _permissions() async {
    // iOS solicita acceso al iniciar BLE.
    // iOS requests access when BLE starts.
    if (!Platform.isAndroid) return true;
    final sdk = (await DeviceInfoPlugin().androidInfo).version.sdkInt;
    final requested =
        await (sdk >= 31
                ? [Permission.bluetoothScan, Permission.bluetoothConnect]
                : [Permission.locationWhenInUse])
            .request();
    if (requested.values.every((value) => value.isGranted)) return true;
    error = 'Permite el acceso a Bluetooth en los ajustes de la app.';
    return false;
  }

  Future<void> search() async {
    if (_disposed || scanning || connecting || connected) return;
    final searchSession = ++_searchSession;
    scanning = true;
    error = null;
    _update();
    try {
      if (!await _permissions()) return;
      if (searchSession != _searchSession) return;
      final adapter = await _ble.statusStream
          .firstWhere((state) => state != BleStatus.unknown)
          .timeout(const Duration(seconds: 5));
      if (searchSession != _searchSession) return;
      if (adapter != BleStatus.ready) {
        error = switch (adapter) {
          BleStatus.poweredOff => 'Activa Bluetooth para buscar el robot.',
          BleStatus.locationServicesDisabled =>
            'Activa la ubicación para buscar en este Android.',
          BleStatus.unsupported => 'Este dispositivo no admite Bluetooth LE.',
          _ => 'Bluetooth no está disponible. Revisa los permisos.',
        };
        return;
      }
      devices.clear();
      scanning = true;
      _scan = _ble
          .scanForDevices(withServices: [], scanMode: ScanMode.lowLatency)
          .listen(
            (device) {
              // Se muestra solo agbot o dispositivos que anuncien su servicio.
              // Only agbot or devices advertising its service are shown.
              if (device.name.toLowerCase() != 'agbot' &&
                  !device.serviceUuids.any(
                    (uuid) => uuid.expanded == _service,
                  )) {
                return;
              }
              final index = devices.indexWhere((item) => item.id == device.id);
              if (index < 0) {
                devices.add(device);
              } else {
                devices[index] = device;
              }
              _update();
            },
            onError: (Object failure) {
              error = 'No se pudo buscar: $failure';
              unawaited(stopSearch());
            },
          );
      _scanTimeout = Timer(
        const Duration(seconds: 10),
        () => unawaited(stopSearch()),
      );
    } catch (failure) {
      error = 'No se pudo iniciar Bluetooth: $failure';
    } finally {
      if (searchSession == _searchSession && _scan == null) scanning = false;
      _update();
    }
  }

  Future<void> stopSearch() async {
    // Invalida también una búsqueda esperando permisos.
    // Also invalidates a scan waiting for permissions.
    ++_searchSession;
    _scanTimeout?.cancel();
    final scan = _scan;
    _scan = null;
    scanning = false;
    _update();
    await scan?.cancel();
  }

  Future<void> connect(DiscoveredDevice device) async {
    if (connecting || connected) return;
    connecting = true;
    error = null;
    deviceName = device.name.isEmpty ? 'agbot' : device.name;
    final session = ++_session;
    _update();
    await stopSearch();
    if (session != _session) return;
    _connection = _ble
        .connectToDevice(
          id: device.id,
          connectionTimeout: const Duration(seconds: 12),
        )
        .listen(
          (event) {
            if (session != _session) return;
            if (event.connectionState == DeviceConnectionState.connected) {
              unawaited(_prepare(device.id, session));
            } else if (event.connectionState ==
                DeviceConnectionState.disconnected) {
              final failure = event.failure;
              unawaited(
                _lost(
                  'El robot se ha desconectado.'
                  '${failure == null ? '' : ' $failure'}',
                ),
              );
            }
          },
          onError: (Object failure) {
            if (session == _session) {
              unawaited(_lost('No se pudo conectar: $failure'));
            }
          },
        );
  }

  Future<void> _prepare(String id, int session) async {
    try {
      await _ble.discoverAllServices(id).timeout(const Duration(seconds: 8));
      if (session != _session) return;
      final services = await _ble.getDiscoveredServices(id);
      if (session != _session) return;
      final matching = services.where(
        (service) => service.id.expanded == _service,
      );
      if (matching.isEmpty ||
          ![_command, _status].every(
            (uuid) => matching.first.characteristics.any(
              (item) => item.id.expanded == uuid,
            ),
          )) {
        throw StateError('El robot no ofrece el servicio FFF0 / FFF1 / FFF2.');
      }
      _writer = QualifiedCharacteristic(
        serviceId: _service,
        characteristicId: _command,
        deviceId: id,
      );
      final reader = QualifiedCharacteristic(
        serviceId: _service,
        characteristicId: _status,
        deviceId: id,
      );
      _notifications = _ble
          .subscribeToCharacteristic(reader)
          .listen(
            (bytes) {
              if (session == _session) _readStatus(bytes);
            },
            onError: (Object failure) {
              if (session == _session) {
                unawaited(_lost('Se perdió la telemetría: $failure'));
              }
            },
          );
      final initial = await _ble
          .readCharacteristic(reader)
          .timeout(const Duration(seconds: 3));
      if (session != _session) return;
      _readStatus(initial);
      if (session != _session) return;
      // Toda conexión comienza con los motores detenidos.
      // Every connection starts with the motors stopped.
      await _ble
          .writeCharacteristicWithResponse(_writer!, value: [0])
          .timeout(const Duration(seconds: 2));
      if (session != _session) return;
      connected = true;
      connecting = false;
      _heartbeat = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (buttons != 0) unawaited(_send());
      });
      _update();
    } catch (failure) {
      if (session == _session) {
        await _lost('Error al preparar el control: $failure');
      }
    }
  }

  void _readStatus(List<int> bytes) {
    try {
      status = RobotStatus.decode(bytes);
      if (status.outputFault) stop();
      _update();
    } on FormatException {
      unawaited(_lost('El robot envió un estado BLE inválido.'));
    }
  }

  // Funciones de conducción: actualizan el estado al pulsar y al soltar.
  // Driving functions: update the state on press and release.
  void acelerar(bool pressed) => _setButton(RobotProtocol.adelante, pressed);
  void retroceder(bool pressed) => _setButton(RobotProtocol.atras, pressed);
  void girarIzquierda(bool pressed) =>
      _setButton(RobotProtocol.izquierda, pressed);
  void girarDerecha(bool pressed) => _setButton(RobotProtocol.derecha, pressed);

  void _setButton(int bit, bool pressed) {
    if (!connected || status.outputFault) return;
    pressed ? _buttons.add(bit) : _buttons.remove(bit);
    _update();
    unawaited(_send());
  }

  void stop() {
    _buttons.clear();
    _update();
    unawaited(_send());
  }

  Future<void> _send() async {
    if (!connected || _writer == null) return;
    _pending = true;
    if (_writing) return;
    _writing = true;
    final session = _session;
    try {
      // Serializa las escrituras y prioriza el estado más reciente.
      // Serializes writes and prioritizes the latest state.
      while (_pending && connected && session == _session) {
        _pending = false;
        await _ble
            .writeCharacteristicWithResponse(_writer!, value: [buttons])
            .timeout(const Duration(milliseconds: 400));
      }
    } catch (failure) {
      if (session == _session) {
        await _lost('Se perdió el envío de órdenes: $failure');
      }
    } finally {
      _writing = false;
    }
  }

  Future<void> disconnect() async {
    stop();
    // _send ya encola la parada; desconectar también detiene el firmware.
    // _send already queues the stop; disconnecting also stops the firmware.
    await _lost(null);
  }

  Future<void> _lost(String? message) async {
    ++_session;
    _heartbeat?.cancel();
    _buttons.clear();
    _pending = false;
    _writer = null;
    connected = false;
    connecting = false;
    status = const RobotStatus();
    error = message;
    _update();
    final notifications = _notifications;
    final connection = _connection;
    _notifications = null;
    _connection = null;
    await notifications?.cancel();
    await connection?.cancel();
  }

  @override
  void dispose() {
    _disposed = true;
    _scanTimeout?.cancel();
    unawaited(stopSearch());
    unawaited(disconnect());
    super.dispose();
  }
}
