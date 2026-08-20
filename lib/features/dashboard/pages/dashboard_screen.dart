import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fitring_companion/features/auth/bloc/auth_bloc.dart';
import 'package:fitring_companion/features/auth/bloc/auth_event.dart';
import 'package:fitring_companion/features/wearable/models/wearable_connection_state.dart';
import 'package:fitring_companion/features/wearable/bloc/wearable_bloc.dart';
import 'package:fitring_companion/features/wearable/bloc/wearable_event.dart';
import 'package:fitring_companion/features/wearable/bloc/wearable_state.dart';
import 'package:fitring_companion/features/dashboard/widgets/connection_status_pill.dart';
import 'package:fitring_companion/features/dashboard/widgets/metric_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FitRing'),
        actions: [
          BlocBuilder<WearableBloc, WearableState>(
            buildWhen: (a, b) => a.connectionState != b.connectionState,
            builder: (context, state) {
              final canRetry = state.connectionState is WearableDisconnected ||
                  state.connectionState is WearableConnectionFailed;
              if (!canRetry) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Reconnect',
                onPressed: () => context
                    .read<WearableBloc>()
                    .add(const WearableReconnectRequested()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
            onPressed: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<WearableBloc, WearableState>(
        builder: (context, state) {
          final reading = state.latestReading;
          final dimmed = state.connectionState is! WearableConnected;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConnectionStatusPill(state: state.connectionState),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.3,
                      children: [
                        MetricTile(
                          label: 'Heart Rate',
                          value: reading == null ? '—' : '${reading.heartRate} BPM',
                          icon: Icons.favorite,
                          dimmed: dimmed,
                        ),
                        MetricTile(
                          label: 'SpO₂',
                          value: reading == null ? '—' : '${reading.spo2}%',
                          icon: Icons.air,
                          dimmed: dimmed,
                        ),
                        MetricTile(
                          label: 'Steps',
                          value: reading == null ? '—' : '${reading.steps}',
                          icon: Icons.directions_walk,
                          dimmed: dimmed,
                        ),
                        MetricTile(
                          label: 'Battery',
                          value: state.batteryLevel == null
                              ? '—'
                              : '${state.batteryLevel}%',
                          icon: Icons.battery_full,
                          dimmed: dimmed,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
