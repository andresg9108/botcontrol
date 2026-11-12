import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../theme/app_colors.dart';

class DevicePicker extends StatelessWidget {
  const DevicePicker({
    super.key,
    required this.devices,
    required this.scanning,
    this.error,
    required this.onSearch,
    required this.onSelected,
  });

  final List<DiscoveredDevice> devices;
  final bool scanning;
  final String? error;
  final VoidCallback onSearch;
  final ValueChanged<DiscoveredDevice> onSelected;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Conectar con agbot',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Enciende el ESP32 y activa el Bluetooth del teléfono.'),
          const SizedBox(height: 20),
          if (scanning) const LinearProgressIndicator(),
          if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                error!,
                style: const TextStyle(color: Colors.orangeAccent),
              ),
            ),
          if (devices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                scanning
                    ? 'Buscando robots cercanos…'
                    : 'No se encontraron robots.',
              ),
            ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final device in devices)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.bluetooth,
                      color: AppColors.accent,
                    ),
                    title: Text(device.name.isEmpty ? 'agbot' : device.name),
                    subtitle: Text('${device.id}\nSeñal: ${device.rssi} dBm'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => onSelected(device),
                  ),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: scanning ? null : onSearch,
            icon: const Icon(Icons.refresh),
            label: const Text('Buscar de nuevo'),
          ),
        ],
      ),
    ),
  );
}
