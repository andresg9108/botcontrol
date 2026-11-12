import 'package:flutter/material.dart';

import '../protocol/robot_protocol.dart';
import 'hold_button.dart';

class DrivingControls extends StatelessWidget {
  const DrivingControls({
    super.key,
    required this.connected,
    required this.outputFault,
    required this.buttons,
    required this.onLeftChanged,
    required this.onRightChanged,
    required this.onForwardChanged,
    required this.onReverseChanged,
    required this.onStop,
  });

  final bool connected;
  final bool outputFault;
  final int buttons;
  final ValueChanged<bool> onLeftChanged;
  final ValueChanged<bool> onRightChanged;
  final ValueChanged<bool> onForwardChanged;
  final ValueChanged<bool> onReverseChanged;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    Widget button(
      String label,
      IconData icon,
      int bit,
      ValueChanged<bool> action,
    ) => HoldButton(
      label: label,
      icon: icon,
      height: double.infinity,
      enabled: connected && !outputFault,
      pressed: buttons & bit != 0,
      onChanged: action,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: button(
                        'IZQUIERDA',
                        Icons.west_rounded,
                        RobotProtocol.izquierda,
                        onLeftChanged,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: button(
                        'DERECHA',
                        Icons.east_rounded,
                        RobotProtocol.derecha,
                        onRightChanged,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: button(
                        'ACELERAR',
                        Icons.north_rounded,
                        RobotProtocol.adelante,
                        onForwardChanged,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: button(
                        'ATRÁS',
                        Icons.south_rounded,
                        RobotProtocol.atras,
                        onReverseChanged,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: connected ? onStop : null,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF42252B),
            foregroundColor: const Color(0xFFFF8D98),
            minimumSize: const Size.fromHeight(44),
          ),
          icon: const Icon(Icons.stop_circle_outlined),
          label: const Text('DETENER'),
        ),
      ],
    );
  }
}
