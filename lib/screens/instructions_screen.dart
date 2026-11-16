import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.raised,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'GUÍA DE CONDUCCIÓN',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tu primera ruta con agbot',
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'El teléfono controla tu robot ESP32 por Bluetooth LE.',
              style: TextStyle(color: AppColors.muted, height: 1.5),
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
                  'En Control, mantén Acelerar para avanzar o Retroceder para '
                  'retroceder. La potencia aumenta progresivamente. Al soltar '
                  'la aceleración, el robot se detiene.',
            ),
            const _Instruction(
              icon: Icons.swap_horiz_rounded,
              title: '3. Combina movimiento y dirección',
              text:
                  'Sin soltar Acelerar o Retroceder, pulsa Izquierda o Derecha con '
                  'otro dedo. El giro por sí solo no mueve el robot. En horizontal, '
                  'los giros están juntos a la izquierda y la marcha a la derecha. '
                  'El icono de ajustes en la barra de Control abre la intensidad '
                  'de giro: de 0 % (recto) a 100 %. Se aplica en ambos sentidos.',
            ),
            const _Instruction(
              icon: Icons.screen_rotation_alt_rounded,
              title: '4. Volante con acelerómetro',
              text:
                  'Activa Control por acelerómetro desde Configuraciones. '
                  'La opción se guarda en este teléfono y viene apagada. '
                  'Al entrar en Control, sostén el teléfono frente a ti: esa '
                  'posición será el centro. Mantén Acelerar o Retroceder y gira '
                  'el teléfono como un volante. Los botones de giro se ocultan; '
                  'la intensidad aumenta entre 5° y 45°. El icono de centrar '
                  'solicita detener y toma una nueva posición central. '
                  'Después de Detener, suelta y vuelve a pulsar para conducir.',
            ),
            const _Instruction(
              icon: Icons.speed_rounded,
              title: '5. Consulta el estado',
              text:
                  'Arriba verás si estás conectado y el nivel de PWM. '
                  'El porcentaje es la potencia PWM reportada por el robot, '
                  'no una medición de velocidad.',
            ),
            const _Instruction(
              icon: Icons.stop_circle_outlined,
              title: '6. Detén y desconecta',
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
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.raised),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.raised,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(color: AppColors.muted, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
