// Cada comando representa todos los botones en un único byte binario.
// Each command represents all buttons in a single binary byte.
abstract final class RobotProtocol {
  static const adelante = 0x01;
  static const atras = 0x02;
  static const izquierda = 0x04;
  static const derecha = 0x08;

  static int command(Set<int> buttons) {
    final mask = buttons.fold(0, (value, bit) => value | bit);
    // Los botones opuestos solicitan parada, igual que en el firmware.
    // Opposing buttons request a stop, just as in the firmware.
    if (mask & 0x03 == 0x03 || mask & 0x0c == 0x0c) return 0;
    return mask;
  }
}

class RobotStatus {
  const RobotStatus({
    this.buttons = 0,
    this.base = 0,
    this.left = 0,
    this.right = 0,
    this.flags = 0,
  });

  factory RobotStatus.decode(List<int> bytes) {
    if (bytes.length != 5) {
      throw const FormatException('El estado BLE debe tener 5 bytes.');
    }
    return RobotStatus(
      buttons: bytes[0],
      base: bytes[1],
      left: bytes[2],
      right: bytes[3],
      flags: bytes[4],
    );
  }

  final int buttons;
  final int base;
  final int left;
  final int right;
  final int flags;
  bool get timedOut => flags & 1 != 0;
  bool get pausing => flags & 2 != 0;
  bool get outputFault => flags & 4 != 0;
}
