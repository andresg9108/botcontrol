import 'package:flutter/material.dart';

import '../protocol/robot_protocol.dart';
import '../theme/app_colors.dart';

class MotorTelemetry extends StatelessWidget {
  const MotorTelemetry({
    super.key,
    required this.connected,
    required this.status,
  });

  final bool connected;
  final RobotStatus status;

  @override
  Widget build(BuildContext context) {
    final label = !connected
        ? 'EN ESPERA'
        : status.outputFault
        ? 'FALLO DE SALIDA'
        : status.timedOut
        ? 'SIN COMANDOS'
        : status.pausing
        ? 'PAUSA DE INVERSIÓN'
        : status.base > 0
        ? 'EN MOVIMIENTO'
        : 'DETENIDO';
    return Tooltip(
      message:
          '$label · PWM izquierdo ${status.left} % · derecho ${status.right} %',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            status.outputFault
                ? label
                : 'Aceleración ${connected ? status.base : 0} %',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: status.outputFault
                  ? Colors.orangeAccent
                  : AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 150,
            child: LinearProgressIndicator(
              value: connected ? (status.base / 100).clamp(0, 1) : 0,
              minHeight: 3,
              borderRadius: BorderRadius.circular(4),
              backgroundColor: Colors.white10,
            ),
          ),
        ],
      ),
    );
  }
}
