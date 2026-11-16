import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:remotecontrol/controllers/robot_controller.dart';
import 'package:remotecontrol/controllers/tilt_steering_controller.dart';
import 'package:remotecontrol/protocol/robot_protocol.dart';

TiltSample sample(double degrees) {
  final radians = degrees * math.pi / 180;
  return TiltSample(-9.8 * math.sin(radians), 9.8 * math.cos(radians), 0);
}

void main() {
  test('Volante proporcional con zona muerta en vertical y horizontal', () {
    for (final center in [0.0, 90.0, -90.0, 175.0]) {
      final angle = SteeringAngle();
      angle.add(sample(center));
      for (var i = 0; i < 40; i++) {
        angle.add(sample(center + 3));
      }
      expect(angle.percent, 0);
      for (var i = 0; i < 40; i++) {
        angle.add(sample(center + 25));
      }
      expect(angle.percent, closeTo(50, 1));
      for (var i = 0; i < 40; i++) {
        angle.add(sample(center - 45));
      }
      expect(angle.percent, -100);
      expect(angle.add(const TiltSample(0, 0, 9.8)), isFalse);
      angle.add(sample(center));
      expect(angle.percent, 0);
    }
  });

  test('El porcentaje manual cambia sin perder las direcciones pulsadas', () {
    final robot = RobotController()..connected = true;
    robot.acelerar(true);
    robot.girarIzquierda(true);
    expect(robot.commandPacket, [5, 50]);
    robot.setManualTurnPercent(25);
    expect(robot.commandPacket, [5, 25]);
    robot.girarIzquierda(false);
    robot.girarDerecha(true);
    robot.setManualTurnPercent(75);
    expect(robot.commandPacket, [9, 75]);
    robot.acelerar(false);
    robot.retroceder(true);
    expect(robot.commandPacket, [10, 75]);
    robot.stop();
    expect(robot.commandPacket, [0, 0]);
    robot.dispose();
  });

  testWidgets(
    'Sensor solo dirige al pulsar; detener no reanuda con lecturas nuevas',
    (tester) async {
      final samples = StreamController<TiltSample>.broadcast(sync: true);
      final robot = RobotController()..connected = true;
      robot.setAccelerometerEnabled(true);
      final tilt = TiltSteeringController(
        robot: robot,
        samples: samples.stream,
      );
      tilt.setActive(true);
      samples.add(sample(0));
      for (var i = 0; i < 30; i++) {
        samples.add(sample(25));
      }
      expect(robot.buttons, 0);
      robot.acelerar(true);
      expect(robot.commandPacket, [9, 50]);
      robot.acelerar(false);
      expect(robot.commandPacket, [0, 0]);
      robot.retroceder(true);
      expect(robot.commandPacket, [10, 50]);
      robot.stop();
      samples.add(sample(30));
      expect(robot.commandPacket, [0, 0]);
      robot.retroceder(false);
      robot.acelerar(true);
      expect(robot.buttons, 9);
      await tester.pump(const Duration(milliseconds: 501));
      expect(robot.buttons, 0);
      expect(tilt.ready, isFalse);
      expect(tilt.error, isNotNull);
      samples.add(sample(0));
      expect(tilt.ready, isTrue);
      expect(robot.buttons, 0);
      tilt.dispose();
      robot.dispose();
      await samples.close();
    },
  );

  testWidgets(
    'Fallo, desconexión y errores del sensor no restauran movimiento',
    (tester) async {
      final samples = StreamController<TiltSample>.broadcast(sync: true);
      final robot = RobotController()..connected = true;
      robot.setAccelerometerEnabled(true);
      final tilt = TiltSteeringController(
        robot: robot,
        samples: samples.stream,
      );
      tilt.setActive(true);
      samples.add(sample(0));
      robot.acelerar(true);
      samples.addError(StateError('sin sensor'));
      expect(robot.buttons, 0);
      expect(tilt.ready, isFalse);
      samples.add(sample(0));
      robot.acelerar(true);
      robot.status = const RobotStatus(flags: 4);
      robot.stop();
      expect(samples.hasListener, isFalse);
      expect(tilt.ready, isFalse);
      robot.status = const RobotStatus();
      robot.stop();
      samples.add(sample(0));
      expect(robot.buttons, 0);
      await robot.disconnect();
      expect(samples.hasListener, isFalse);
      robot.connected = true;
      robot.stop();
      samples.add(sample(90));
      expect(tilt.percent, 0);
      expect(robot.buttons, 0);
      tilt.dispose();
      robot.dispose();
      await samples.close();
    },
  );
}
