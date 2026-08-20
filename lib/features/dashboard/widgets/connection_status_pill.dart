import 'package:flutter/material.dart';

import 'package:fitring_companion/core/theme/app_theme.dart';
import 'package:fitring_companion/features/wearable/models/wearable_connection_state.dart';

class ConnectionStatusPill extends StatelessWidget {
  const ConnectionStatusPill({super.key, required this.state});

  final WearableConnectionState state;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      WearableConnected() => ('Connected', AppTheme.accent),
      WearableConnecting() => ('Connecting…', AppTheme.warn),
      WearableReconnecting(attempt: final a) => (
          'Reconnecting (attempt $a)…',
          AppTheme.warn,
        ),
      WearableConnectionFailed() => ('Connection failed', AppTheme.bad),
      WearableDisconnected() => ('Disconnected', Colors.grey),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
