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
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.bluetooth_searching_rounded,
              size: 36,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Conectar con agbot',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enciende el ESP32 y activa el Bluetooth del teléfono.',
            style: TextStyle(color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 20),
          if (scanning) const LinearProgressIndicator(),
          if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                error!,
                style: const TextStyle(color: AppColors.danger, height: 1.5),
              ),
            ),
          if (devices.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.raised,
                borderRadius: BorderRadius.circular(16),
              ),
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
              padding: EdgeInsets.zero,
              children: [
                for (final device in devices)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    leading: const Icon(
                      Icons.bluetooth,
                      color: AppColors.accent,
                    ),
                    title: Text(
                      device.name.isEmpty ? 'agbot' : device.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
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
