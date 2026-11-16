import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class SettingsStore {
  SettingsStore({Future<Directory> Function()? directory})
    : _directory = directory ?? getApplicationSupportDirectory;

  final Future<Directory> Function() _directory;

  Future<File> _file() async {
    final directory = await _directory();
    await directory.create(recursive: true);
    return File('${directory.path}/settings.json');
  }

  Future<bool> read() async {
    final file = await _file();
    if (!await file.exists()) return false;
    final data = jsonDecode(await file.readAsString());
    if (data is! Map<String, dynamic> ||
        data['accelerometerEnabled'] is! bool) {
      throw const FormatException('Configuración inválida');
    }
    return data['accelerometerEnabled'] as bool;
  }

  Future<void> write(bool enabled) async {
    final file = await _file();
    final temporary = File('${file.path}.tmp');
    await temporary.writeAsString(
      jsonEncode({'accelerometerEnabled': enabled}),
      flush: true,
    );
    await temporary.rename(file.path);
  }
}

class SettingsController extends ChangeNotifier {
  SettingsController({SettingsStore? store})
    : _store = store ?? SettingsStore();

  final SettingsStore _store;
  bool accelerometerEnabled = false;
  bool loaded = false;
  bool saving = false;
  bool _disposed = false;
  String? error;

  void _update() {
    if (!_disposed) notifyListeners();
  }

  Future<void> load() async {
    try {
      accelerometerEnabled = await _store.read();
      error = null;
    } catch (_) {
      error = 'No se pudo leer la configuración. Se usará el control manual.';
    }
    loaded = true;
    _update();
  }

  Future<void> setAccelerometerEnabled(bool enabled) async {
    if (!loaded || saving || enabled == accelerometerEnabled) return;
    saving = true;
    error = null;
    _update();
    try {
      await _store.write(enabled);
      accelerometerEnabled = enabled;
    } catch (_) {
      error = 'No se pudo guardar la configuración. Inténtalo de nuevo.';
    } finally {
      saving = false;
      _update();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
