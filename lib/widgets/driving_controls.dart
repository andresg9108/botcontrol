import 'package:flutter/material.dart';

import '../protocol/robot_protocol.dart';
import '../theme/app_colors.dart';
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
    final textScale = MediaQuery.textScalerOf(context).scale(12) / 12;
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
          child: LayoutBuilder(
            builder: (context, constraints) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: SizedBox(
                  height: constraints.maxHeight.clamp(0, 320 * textScale),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Center(
                          child: SizedBox(
                            height: constraints.maxHeight.clamp(
                              0,
                              112 * textScale,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: button(
                                    'IZQUIERDA',
                                    Icons.arrow_circle_left_rounded,
                                    RobotProtocol.izquierda,
                                    onLeftChanged,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: button(
                                    'DERECHA',
                                    Icons.arrow_circle_right_rounded,
                                    RobotProtocol.derecha,
                                    onRightChanged,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: button(
                                'ACELERAR',
                                Icons.arrow_circle_up_rounded,
                                RobotProtocol.adelante,
                                onForwardChanged,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: button(
                                'RETROCEDER',
                                Icons.arrow_circle_down_rounded,
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
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: connected ? onStop : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.dangerSurface,
                  foregroundColor: AppColors.danger,
                  disabledBackgroundColor: AppColors.panel,
                  disabledForegroundColor: AppColors.muted,
                  side: BorderSide(
                    color: connected ? AppColors.danger : AppColors.outline,
                  ),
                  minimumSize: const Size.fromHeight(52),
                ),
                icon: const Icon(Icons.stop_circle_outlined),
                label: const Text('DETENER'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
