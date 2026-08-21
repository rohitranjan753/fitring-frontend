import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import 'package:fitring_companion/core/network/api_client.dart';
import 'package:fitring_companion/features/devices/services/device_id_cache.dart';
import 'package:fitring_companion/features/devices/services/devices_api.dart';
import 'package:fitring_companion/features/wearable/models/health_reading.dart';
import 'package:fitring_companion/features/wearable/repositories/wearable_repository.dart';
import 'package:fitring_companion/features/health/repositories/health_repository.dart';
import 'package:fitring_companion/features/health/services/app_database.dart';

/// Implements the "local-first" story from the PRD in one place:
///  - listens to the wearable and saves every reading locally as it arrives
///  - tries to sync to the backend right away, but never blocks on it
///  - retries automatically whenever connectivity comes back
class HealthRepositoryImpl implements HealthRepository {
  HealthRepositoryImpl(
    this._db,
    this._api,
    this._devicesApi,
    this._deviceIdCache,
    WearableRepository wearable,
  ) {
    _readingsSub = wearable.readings.listen(saveReading);
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (!results.contains(ConnectivityResult.none)) {
        syncPendingReadings();
      }
    });
  }

  final AppDatabase _db;
  final ApiClient _api;
  final DevicesApi _devicesApi;
  final DeviceIdCache _deviceIdCache;
  late final StreamSubscription<HealthReading> _readingsSub;
  late final StreamSubscription<List<ConnectivityResult>> _connectivitySub;

  static const _syncBatchSize = 50;

  /// In-memory only — DeviceIdCache is the source of truth across restarts.
  final Map<String, String> _resolvedBackendIds = {};

  /// Every saveReading() opportunistically calls syncPendingReadings(), and
  /// the wearable emits readings every few seconds — without this guard, a
  /// burst of readings arriving faster than one sync round-trip completes
  /// would spawn overlapping syncs, each re-reading the same unsynced rows
  /// and re-POSTing overlapping batches. One sync in flight at a time; a
  /// trigger that arrives while one is running just sets this so the loop
  /// takes one more pass once the current sync finishes, picking up
  /// whatever arrived meanwhile.
  bool _syncInFlight = false;
  bool _syncRequestedAgain = false;

  /// The backend expects `deviceId` to be its own device UUID, but every
  /// reading the wearable emits is tagged with the vendor externalId (e.g.
  /// "FITRING-001") instead — the two are never the same value. This
  /// resolves one to the other, registering the device on first use
  /// (POST /devices), then caching the result so it's a local lookup after
  /// that. Returns null when the backend can't be reached right now — the
  /// caller leaves the batch unsynced and retries on the next sync trigger.
  Future<String?> _resolveBackendDeviceId(String externalId) async {
    final cached = _resolvedBackendIds[externalId] ?? await _deviceIdCache.read(externalId);
    if (cached != null) {
      _resolvedBackendIds[externalId] = cached;
      return cached;
    }

    try {
      final devices = await _devicesApi.listDevices();
      final existing = devices.where((d) => d.externalId == externalId).firstOrNull;
      final device = existing ?? await _registerDevice(externalId);
      _resolvedBackendIds[externalId] = device.id;
      await _deviceIdCache.write(externalId, device.id);
      return device.id;
    } on DioException {
      return null;
    }
  }

  Future<DeviceDto> _registerDevice(String externalId) async {
    try {
      return await _devicesApi.registerDevice(externalId: externalId, name: externalId);
    } on DioException catch (e) {
      // Another sync attempt (or another session) won the race and already
      // registered this externalId — look it up instead of failing.
      if (e.response?.statusCode == 409) {
        final devices = await _devicesApi.listDevices();
        final device = devices.where((d) => d.externalId == externalId).firstOrNull;
        if (device != null) return device;
      }
      rethrow;
    }
  }

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
    if (_syncInFlight) {
      _syncRequestedAgain = true;
      return;
    }
    _syncInFlight = true;
    try {
      do {
        _syncRequestedAgain = false;
        await _syncPendingReadingsOnce();
      } while (_syncRequestedAgain);
    } finally {
      _syncInFlight = false;
    }
  }

  Future<void> _syncPendingReadingsOnce() async {
    final pending = await (_db.select(_db.healthReadingsTable)
          ..where((t) => t.synced.equals(false))
          ..limit(_syncBatchSize))
        .get();
    if (pending.isEmpty) return;

    // The backend expects one deviceId per request, so group by device
    // (in practice there's only ever one device, but this stays correct
    // if that ever changes). Rows group by the vendor externalId, which is
    // what's actually stored locally — translated to the backend's UUID
    // just before it goes out over the wire.
    final byDevice = <String, List<HealthReadingsTableData>>{};
    for (final row in pending) {
      byDevice.putIfAbsent(row.deviceId, () => []).add(row);
    }

    for (final entry in byDevice.entries) {
      final backendDeviceId = await _resolveBackendDeviceId(entry.key);
      if (backendDeviceId == null) continue; // offline/unreachable — retry later

      try {
        await _api.dio.post<void>(
          '/health/readings',
          data: {
            'deviceId': backendDeviceId,
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
