import 'dart:math' as math;

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
    builder: (context, _) => LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: SizedBox(
          height: math.max(260, constraints.maxHeight - 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: controller.connected
                        ? AppColors.accent
                        : Colors.white38,
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
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: MotorTelemetry(
                      connected: controller.connected,
                      status: controller.status,
                    ),
                  ),
                ],
              ),
              if (controller.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    controller.error!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
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
  );
}
