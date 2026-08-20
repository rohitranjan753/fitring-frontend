import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fitring_companion/core/theme/app_theme.dart';
import 'package:fitring_companion/core/widgets/error_banner.dart';
import 'package:fitring_companion/features/health/repositories/health_repository.dart';
import 'package:fitring_companion/features/history/bloc/history_cubit.dart';
import 'package:fitring_companion/features/history/widgets/health_line_chart.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: BlocConsumer<HistoryCubit, HistoryState>(
        listenWhen: (previous, current) => current.errorMessage != null && current.readings.isNotEmpty,
        listener: (context, state) => showErrorBanner(context, state.errorMessage!),
        builder: (context, state) {
          if (state.isLoading && state.readings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => context.read<HistoryCubit>().load(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SyncStatusBanner(pendingCount: state.pendingSyncCount),
                const SizedBox(height: 20),
                if (state.dailySummary.isNotEmpty) ...[
                  Text('Weekly summary', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  HealthLineChart(
                    title: 'Heart Rate (avg/day)',
                    values: state.dailySummary.map((d) => d.avgHeartRate).toList(),
                    color: AppTheme.accent,
                  ),
                  const SizedBox(height: 20),
                  HealthLineChart(
                    title: 'SpO₂ (avg/day)',
                    values: state.dailySummary.map((d) => d.avgSpo2).toList(),
                    color: AppTheme.warn,
                  ),
                  const SizedBox(height: 20),
                  Text('Steps per day', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...state.dailySummary.map((d) => _StepsRow(summary: d)),
                  const SizedBox(height: 24),
                ],
                Text('Daily history', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                if (state.readings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No readings yet — keep the app open for a bit.'),
                  ),
                ...state.readings.map(
                  (r) => ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.favorite, size: 18),
                    title: Text('${r.heartRate} BPM · SpO₂ ${r.spo2}% · ${r.steps} steps'),
                    subtitle: Text(DateFormat('MMM d, h:mm a').format(r.recordedAt.toLocal())),
                  ),
                ),
                if (state.readings.isNotEmpty)
                  Center(
                    child: TextButton(
                      onPressed: () => context.read<HistoryCubit>().loadMore(),
                      child: const Text('Load more'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SyncStatusBanner extends StatelessWidget {
  const _SyncStatusBanner({required this.pendingCount});

  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final synced = pendingCount == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: (synced ? AppTheme.accent : AppTheme.warn).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            synced ? Icons.cloud_done_outlined : Icons.cloud_upload_outlined,
            size: 18,
            color: synced ? AppTheme.accent : AppTheme.warn,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              synced ? 'All readings synced' : '$pendingCount reading(s) waiting to sync',
            ),
          ),
          if (!synced)
            TextButton(
              onPressed: () => context.read<HistoryCubit>().syncNow(),
              child: const Text('Sync now'),
            ),
        ],
      ),
    );
  }
}

class _StepsRow extends StatelessWidget {
  const _StepsRow({required this.summary});

  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(DateFormat('MMM d').format(summary.day))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (summary.steps / 10000).clamp(0, 1),
                minHeight: 8,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                color: AppTheme.accent,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('${summary.steps}'),
        ],
      ),
    );
  }
}
