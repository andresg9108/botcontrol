import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tu primera ruta con agbot',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'El teléfono controla tu robot ESP32 por Bluetooth LE.',
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 24),
            const _Instruction(
              icon: Icons.bluetooth_searching,
              title: '1. Conecta tu robot',
              text:
                  'Enciende agbot y activa Bluetooth. Abre el menú ☰, pulsa '
                  'Conectar y selecciona agbot. Acepta los permisos solicitados. '
                  'En Android 11 o anterior, activa también la ubicación. '
                  'La conexión se realiza desde la app, sin emparejar en ajustes.',
            ),
            const _Instruction(
              icon: Icons.touch_app_outlined,
              title: '2. Mantén pulsado para avanzar',
              text:
                  'En Control, mantén Acelerar para avanzar o Atrás para '
                  'retroceder. La potencia aumenta progresivamente. Al soltar '
                  'la aceleración, el robot se detiene.',
            ),
            const _Instruction(
              icon: Icons.swap_horiz_rounded,
              title: '3. Combina movimiento y dirección',
              text:
                  'Sin soltar Acelerar o Atrás, pulsa Izquierda o Derecha con '
                  'otro dedo. El giro por sí solo no mueve el robot. En horizontal, '
                  'los giros están juntos a la izquierda y la marcha a la derecha.',
            ),
            const _Instruction(
              icon: Icons.speed_rounded,
              title: '4. Consulta el estado',
              text:
                  'Arriba verás si estás conectado y el nivel de aceleración. '
                  'El porcentaje es la potencia PWM reportada por el robot, '
                  'no una medición de velocidad.',
            ),
            const _Instruction(
              icon: Icons.stop_circle_outlined,
              title: '5. Detén y desconecta',
              text:
                  'Pulsa Detener para liberar todos los controles. Abrir el '
                  'menú, cambiar de pantalla o salir de la app también libera '
                  'los botones. Para terminar, abre el menú y pulsa Desconectar.',
            ),
          ],
        ),
      ),
    ),
  );
}

class _Instruction extends StatelessWidget {
  const _Instruction({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.accent),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text(
                text,
                style: const TextStyle(color: Colors.white70, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
