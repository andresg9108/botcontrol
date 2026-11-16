import 'package:flutter/material.dart';

import '../protocol/robot_protocol.dart';
import '../theme/app_colors.dart';

class MotorTelemetry extends StatelessWidget {
  const MotorTelemetry({
    super.key,
    required this.connected,
    required this.status,
    required this.buttons,
    required this.turnPercent,
    this.compact = false,
  });

  final bool connected;
  final RobotStatus status;
  final int buttons;
  final int turnPercent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final motion = !connected ? 0 : status.buttons & 3;
    final movement = motion == RobotProtocol.adelante
        ? 'Avance'
        : motion == RobotProtocol.atras
        ? 'Retroceso'
        : 'Detenido';
    final steering = !connected || status.outputFault ? 0 : buttons & 12;
    final direction = steering == RobotProtocol.izquierda
        ? 'Izquierda'
        : steering == RobotProtocol.derecha
        ? 'Derecha'
        : 'Recto';
    final percent = steering == 0 ? 0 : turnPercent;
    final base = connected ? status.base : 0;
    final fault = connected && status.outputFault;
    final exceptional =
        connected && (status.outputFault || status.timedOut || status.pausing);
    final powerColor = !connected
        ? AppColors.muted
        : fault
        ? AppColors.danger
        : AppColors.accent;
    final steeringColor = !connected || fault
        ? AppColors.muted
        : AppColors.accent;
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
      excludeFromSemantics: compact,
      message:
          '$label · $movement $base % PWM · Giro solicitado: $direction $percent % · PWM izquierdo ${connected ? status.left : 0} % · derecho ${connected ? status.right : 0} %',
      child: compact
          ? LayoutBuilder(
              builder: (context, constraints) {
                final horizontal =
                    constraints.maxWidth >=
                    MediaQuery.textScalerOf(context).scale(12) * 10 + 60;
                return Flex(
                  direction: horizontal ? Axis.horizontal : Axis.vertical,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      flex: horizontal ? 1 : 0,
                      child: _CompactPower(
                        icon: connected && status.outputFault
                            ? Icons.warning_amber_rounded
                            : connected && status.timedOut
                            ? Icons.timer_off_outlined
                            : connected && status.pausing
                            ? Icons.pause_circle_outline_rounded
                            : motion == RobotProtocol.adelante
                            ? Icons.arrow_upward_rounded
                            : motion == RobotProtocol.atras
                            ? Icons.arrow_downward_rounded
                            : Icons.stop_circle_outlined,
                        label: '$label · $movement · $base % PWM',
                        percent: base,
                        color: powerColor,
                      ),
                    ),
                    SizedBox(
                      width: horizontal ? 8 : 0,
                      height: horizontal ? 0 : 4,
                    ),
                    Flexible(
                      flex: horizontal ? 1 : 0,
                      child: _CompactPower(
                        icon: steering == RobotProtocol.izquierda
                            ? Icons.arrow_back_rounded
                            : steering == RobotProtocol.derecha
                            ? Icons.arrow_forward_rounded
                            : Icons.straight_rounded,
                        label: 'Giro solicitado · $direction · $percent %',
                        percent: percent,
                        color: steeringColor,
                      ),
                    ),
                  ],
                );
              },
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  exceptional
                      ? '$label · $base % PWM'
                      : '$movement · $base % PWM',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: powerColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Giro · $direction $percent %',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: steeringColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

class _CompactPower extends StatelessWidget {
  const _CompactPower({
    required this.icon,
    required this.label,
    required this.percent,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    excludeFromSemantics: true,
    child: Semantics(
      label: label,
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            '$percent %',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}
