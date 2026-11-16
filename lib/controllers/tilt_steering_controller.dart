import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'robot_controller.dart';

class TiltSample {
  const TiltSample(this.x, this.y, this.z);
  final double x;
  final double y;
  final double z;
}

/// Usa la gravedad en el plano de la pantalla, como un volante frente al usuario.
class SteeringAngle {
  double? _x;
  double? _y;
  double? _center;
  double degrees = 0;

  bool add(TiltSample sample) {
    if (!sample.x.isFinite ||
        !sample.y.isFinite ||
        !sample.z.isFinite ||
        math.sqrt(sample.x * sample.x + sample.y * sample.y) < 3) {
      reset();
      return false;
    }
    _x = _x == null ? sample.x : _x! * 0.75 + sample.x * 0.25;
    _y = _y == null ? sample.y : _y! * 0.75 + sample.y * 0.25;
    final angle = math.atan2(-_x!, _y!) * 180 / math.pi;
    _center ??= angle;
    degrees = (angle - _center! + 180) % 360 - 180;
    return true;
  }

  int get percent {
    // 5° de zona muerta; 45° alcanza el giro máximo.
    final magnitude = ((degrees.abs() - 5) / 40 * 100).clamp(0, 100).round();
    return degrees < 0 ? -magnitude : magnitude;
  }

  void reset() {
    _x = null;
    _y = null;
    _center = null;
    degrees = 0;
  }
}

class TiltSteeringController extends ChangeNotifier {
  TiltSteeringController({required this.robot, this.samples}) {
    robot.addListener(_robotChanged);
  }

  final RobotController robot;
  final Stream<TiltSample>? samples;
  final angle = SteeringAngle();
  StreamSubscription<TiltSample>? _subscription;
  bool _active = false;
  bool _handling = false;
  bool _disposed = false;
  int _generation = 0;
  bool ready = false;
  String? error;
  int get percent => angle.percent;

  void setActive(bool active) {
    _active = active;
    _robotChanged();
  }

  void _robotChanged() {
    if (_disposed || _handling) return;
    _handling = true;
    try {
      final shouldRun = _active && robot.connected && !robot.status.outputFault;
      if (!shouldRun) {
        _cancel();
      } else if (_subscription == null) {
        _start();
      } else if (ready && robot.buttons & 3 != 0) {
        robot.setTiltSteering(percent);
      }
    } finally {
      _handling = false;
    }
  }

  void _start() {
    final generation = ++_generation;
    try {
      final source =
          samples ??
          accelerometerEventStream(
            samplingPeriod: const Duration(milliseconds: 50),
          ).map((event) => TiltSample(event.x, event.y, event.z));
      _subscription = source
          .timeout(const Duration(milliseconds: 500))
          .listen(
            (sample) {
              if (_disposed || generation != _generation) return;
              if (!angle.add(sample)) {
                _fail('Sostén el teléfono frente a ti, como un volante.');
                return;
              }
              ready = true;
              error = null;
              robot.setTiltSteering(percent);
              notifyListeners();
            },
            onError: (Object failure) {
              if (!_disposed && generation == _generation) {
                _fail(
                  'Sin datos del acelerómetro. Revisa el sensor o usa el modo manual.',
                );
              }
            },
            onDone: () {
              if (!_disposed && generation == _generation) {
                _fail(
                  'El acelerómetro dejó de enviar datos. Vuelve a entrar en Control.',
                );
              }
            },
          );
    } catch (_) {
      _fail('El acelerómetro no está disponible. Usa el modo manual.');
    }
  }

  void _fail(String message) {
    ready = false;
    error = message;
    angle.reset();
    robot.stop();
    notifyListeners();
  }

  void recenter() {
    robot.stop();
    angle.reset();
    ready = false;
    error = null;
    notifyListeners();
  }

  void _cancel() {
    ++_generation;
    final subscription = _subscription;
    _subscription = null;
    unawaited(subscription?.cancel());
    angle.reset();
    ready = false;
    error = null;
  }

  @override
  void dispose() {
    _disposed = true;
    robot.removeListener(_robotChanged);
    _cancel();
    super.dispose();
  }
}
