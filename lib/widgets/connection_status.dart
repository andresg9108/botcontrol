import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ConnectionStatus extends StatelessWidget {
  const ConnectionStatus({
    super.key,
    required this.connected,
    required this.connecting,
    this.deviceName,
    required this.onConnect,
    required this.onDisconnect,
  });

  final bool connected;
  final bool connecting;
  final String? deviceName;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: connected ? AppColors.accent : AppColors.outline,
      ),
    ),
    child: Wrap(
      spacing: 16,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              connected
                  ? Icons.bluetooth_connected_rounded
                  : Icons.bluetooth_searching_rounded,
              size: 24,
              color: connected ? AppColors.accent : AppColors.muted,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    connected
                        ? deviceName ?? 'agbot'
                        : connecting
                        ? 'Conectando…'
                        : 'Sin conexión',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    connected
                        ? 'Bluetooth LE conectado'
                        : connecting
                        ? 'Preparando el control…'
                        : 'Busca tu robot por Bluetooth',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        FilledButton.icon(
          onPressed: connecting || connected ? onDisconnect : onConnect,
          icon: Icon(
            connected || connecting
                ? Icons.link_off
                : Icons.bluetooth_searching,
            size: 18,
          ),
          label: Text(
            connecting
                ? 'Cancelar'
                : connected
                ? 'Desconectar'
                : 'Conectar',
          ),
        ),
      ],
    ),
  );
}
