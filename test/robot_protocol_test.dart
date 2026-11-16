import 'package:flutter_test/flutter_test.dart';
import 'package:remotecontrol/protocol/robot_protocol.dart';

void main() {
  test('Codifica los dos bytes documentados por el firmware', () {
    expect(RobotProtocol.packet(5, 25), [0x05, 0x19]);
    expect(RobotProtocol.packet(9, 75), [0x09, 0x4b]);
    expect(RobotProtocol.packet(6, 100), [0x06, 0x64]);
    expect(RobotProtocol.packet(10, 35), [0x0a, 35]);
    expect(RobotProtocol.packet(5, 0), [5, 0]);
    expect(RobotProtocol.packet(1, 75), [1, 0]);
    expect(RobotProtocol.packet(0, 50), [0, 0]);
    for (final buttons in [3, 12, 16, -1]) {
      expect(RobotProtocol.packet(buttons, 50), [0, 0]);
    }
    expect(RobotProtocol.packet(5, 101), [0, 0]);
    expect(RobotProtocol.packet(5, -1), [0, 0]);
  });

  test('Los movimientos combinados coinciden con el protocolo del ESP32', () {
    expect(RobotProtocol.command({}), 0x00);
    expect(RobotProtocol.command({RobotProtocol.adelante}), 0x01);
    expect(RobotProtocol.command({RobotProtocol.atras}), 0x02);
    expect(
      RobotProtocol.command({RobotProtocol.adelante, RobotProtocol.izquierda}),
      0x05,
    );
    expect(
      RobotProtocol.command({RobotProtocol.adelante, RobotProtocol.derecha}),
      0x09,
    );
    expect(
      RobotProtocol.command({RobotProtocol.atras, RobotProtocol.izquierda}),
      0x06,
    );
    expect(
      RobotProtocol.command({RobotProtocol.atras, RobotProtocol.derecha}),
      0x0a,
    );
  });

  test('Las direcciones opuestas solicitan parada', () {
    expect(RobotProtocol.command({1, 2}), 0);
    expect(RobotProtocol.command({1, 4, 8}), 0);
  });

  test('Interpreta el paquete de telemetría y sus flags', () {
    final status = RobotStatus.decode([5, 80, 40, 80, 7]);
    expect(status.buttons, 5);
    expect(status.base, 80);
    expect(status.left, 40);
    expect(status.right, 80);
    expect(status.timedOut, isTrue);
    expect(status.pausing, isTrue);
    expect(status.outputFault, isTrue);
    expect(() => RobotStatus.decode([0]), throwsFormatException);
  });
}
