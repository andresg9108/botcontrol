import 'package:flutter/material.dart';

import '../controllers/settings_controller.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onChanged,
  });

  final SettingsController settings;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: settings,
    builder: (context, _) => Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.screen_rotation_alt_rounded),
              title: const Text('Control por acelerómetro'),
              subtitle: const Text(
                'Gira el teléfono como un volante mientras mantienes pulsado ACELERAR o RETROCEDER.',
              ),
              value: settings.accelerometerEnabled,
              onChanged: settings.loaded && !settings.saving ? onChanged : null,
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Al activarlo se ocultan los botones de giro. Sostén el teléfono frente a ti al entrar en Control: esa posición será el centro. El giro aumenta entre 5° y 45°. Puedes volver a centrarlo desde el control.\n\nLos cambios se guardan en los archivos privados de la app en este teléfono.',
                style: TextStyle(color: AppColors.muted, height: 1.5),
              ),
            ),
            if (!settings.loaded || settings.saving)
              const LinearProgressIndicator(),
            if (settings.error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  settings.error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
