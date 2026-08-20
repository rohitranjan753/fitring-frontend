import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';

import 'package:fitring_companion/core/network/api_client.dart';
import 'package:fitring_companion/features/wearable/models/health_reading.dart';
import 'package:fitring_companion/features/wearable/repositories/wearable_repository.dart';
import 'package:fitring_companion/features/health/repositories/health_repository.dart';
import 'package:fitring_companion/features/health/services/app_database.dart';

/// Implements the "local-first" story from the PRD in one place:
///  - listens to the wearable and saves every reading locally as it arrives
///  - tries to sync to the backend right away, but never blocks on it
///  - retries automatically whenever connectivity comes back
class HealthRepositoryImpl implements HealthRepository {
  HealthRepositoryImpl(this._db, this._api, WearableRepository wearable) {
    _readingsSub = wearable.readings.listen(saveReading);
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        syncPendingReadings();
      }
    });
  }

  final AppDatabase _db;
  final ApiClient _api;
  late final StreamSubscription<HealthReading> _readingsSub;
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;

  static const _syncBatchSize = 50;

  @override
  Future<void> saveReading(HealthReading reading) async {
    // `insertOnConflictUpdate` resolves conflicts on the primary key (`id`,
    // an autoincrement that's never actually reused) by default — it would
    // NOT catch a retried reading with the same clientUuid, which is the
    // constraint that actually matters here. `target:` points the upsert
    // at the right column.
    await _db
        .into(_db.healthReadingsTable)
        .insert(
          HealthReadingsTableCompanion.insert(
            clientUuid: reading.id,
            deviceId: reading.deviceId,
            heartRate: reading.heartRate,
            spo2: reading.spo2,
            steps: reading.steps,
            recordedAt: reading.recordedAt,
          ),
          onConflict: DoUpdate(
            (old) => HealthReadingsTableCompanion.insert(
              clientUuid: reading.id,
              deviceId: reading.deviceId,
              heartRate: reading.heartRate,
              spo2: reading.spo2,
              steps: reading.steps,
              recordedAt: reading.recordedAt,
            ),
            target: [_db.healthReadingsTable.clientUuid],
          ),
        );
    unawaited(syncPendingReadings());
  }

  @override
  Future<List<HealthReading>> recentReadings({int limit = 50}) async {
    final rows = await (_db.select(_db.healthReadingsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)])
          ..limit(limit))
        .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<DailySummary>> dailySummary({int days = 7}) async {
    final cutoff = DateTime.now().toUtc().subtract(Duration(days: days));
    final rows = await (_db.select(
      _db.healthReadingsTable,
    )..where((t) => t.recordedAt.isBiggerOrEqualValue(cutoff))).get();

    // Grouping in plain Dart, not SQL — at this data scale (a demo app,
    // not millions of rows) it's simpler to read than fighting SQLite's
    // date functions, and just as correct.
    final byDay = <DateTime, List<HealthReadingsTableData>>{};
    for (final row in rows) {
      final local = row.recordedAt.toLocal();
      final day = DateTime(local.year, local.month, local.day);
      byDay.putIfAbsent(day, () => []).add(row);
    }

    final summaries = byDay.entries.map((entry) {
      final readings = entry.value;
      final avgHr = readings.map((r) => r.heartRate).reduce((a, b) => a + b) / readings.length;
      final avgSpo2 = readings.map((r) => r.spo2).reduce((a, b) => a + b) / readings.length;
      final maxSteps = readings.map((r) => r.steps).reduce((a, b) => a > b ? a : b);
      return DailySummary(day: entry.key, avgHeartRate: avgHr, avgSpo2: avgSpo2, steps: maxSteps);
    }).toList()
      ..sort((a, b) => a.day.compareTo(b.day));

    return summaries;
  }

  @override
  Future<int> pendingSyncCount() async {
    final rows = await (_db.select(
      _db.healthReadingsTable,
    )..where((t) => t.synced.equals(false))).get();
    return rows.length;
  }

  @override
  Future<void> syncPendingReadings() async {
    final pending = await (_db.select(_db.healthReadingsTable)
          ..where((t) => t.synced.equals(false))
          ..limit(_syncBatchSize))
        .get();
    if (pending.isEmpty) return;

    // The backend expects one deviceId per request, so group by device
    // (in practice there's only ever one device, but this stays correct
    // if that ever changes).
    final byDevice = <String, List<HealthReadingsTableData>>{};
    for (final row in pending) {
      byDevice.putIfAbsent(row.deviceId, () => []).add(row);
    }

    for (final entry in byDevice.entries) {
      try {
        await _api.dio.post<void>(
          '/health/readings',
          data: {
            'deviceId': entry.key,
            'readings': entry.value
                .map(
                  (r) => {
                    'clientUuid': r.clientUuid,
                    'heartRate': r.heartRate,
                    'spo2': r.spo2,
                    'steps': r.steps,
                    'recordedAt': r.recordedAt.toUtc().toIso8601String(),
                  },
                )
                .toList(),
          },
        );
        // The backend treats duplicates as accepted too (idempotent), so a
        // successful response always means every row in this batch is safe
        // to mark synced.
        await (_db.update(_db.healthReadingsTable)
              ..where((t) => t.id.isIn(entry.value.map((r) => r.id))))
            .write(const HealthReadingsTableCompanion(synced: Value(true)));
      } catch (_) {
        // Offline, or the backend is down — leave these rows unsynced.
        // The next connectivity change or saveReading() call retries them.
      }
    }
  }

  HealthReading _toEntity(HealthReadingsTableData row) {
    return HealthReading(
      id: row.clientUuid,
      deviceId: row.deviceId,
      heartRate: row.heartRate,
      spo2: row.spo2,
      steps: row.steps,
      recordedAt: row.recordedAt,
    );
  }

  Future<void> dispose() async {
    await _readingsSub.cancel();
    await _connectivitySub.cancel();
  }
}
