import 'package:flutter/material.dart';

import '../controllers/robot_controller.dart';
import '../theme/app_colors.dart';
import '../widgets/driving_controls.dart';
import '../widgets/motor_telemetry.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key, required this.controller});

  final RobotController controller;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: controller,
    builder: (context, _) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: LayoutBuilder(
          builder: (context, constraints) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(constraints.maxHeight < 344 ? 4 : 12),
                  decoration: BoxDecoration(
                    color: AppColors.panel,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.raised),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        controller.connected
                            ? Icons.bluetooth_connected_rounded
                            : Icons.bluetooth_disabled_rounded,
                        size: 22,
                        color: controller.connected
                            ? AppColors.accent
                            : AppColors.muted,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.connected
                              ? 'Conectado · ${controller.deviceName ?? 'agbot'}'
                              : controller.connecting
                              ? 'Conectando…'
                              : 'Sin conexión',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MotorTelemetry(
                          connected: controller.connected,
                          status: controller.status,
                        ),
                      ),
                    ],
                  ),
                ),
                if (controller.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 80),
                      child: SingleChildScrollView(
                        child: Text(
                          controller.error!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: DrivingControls(
                    connected: controller.connected,
                    outputFault: controller.status.outputFault,
                    buttons: controller.buttons,
                    onLeftChanged: controller.girarIzquierda,
                    onRightChanged: controller.girarDerecha,
                    onForwardChanged: controller.acelerar,
                    onReverseChanged: controller.retroceder,
                    onStop: controller.stop,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
