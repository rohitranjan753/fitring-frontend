import 'package:fitring_companion/features/wearable/models/health_reading.dart';

class DailySummary {
  const DailySummary({
    required this.day,
    required this.avgHeartRate,
    required this.avgSpo2,
    required this.steps,
  });

  final DateTime day;
  final double avgHeartRate;
  final double avgSpo2;
  final int steps;
}

abstract class HealthRepository {
  /// Saves a reading locally and, if online, tries to sync it right away.
  /// Works the same whether the app has internet or not — the reading is
  /// never lost, only its upload gets delayed.
  Future<void> saveReading(HealthReading reading);

  /// Most recent readings first, capped at [limit] — the History screen
  /// never loads the whole table into memory at once.
  Future<List<HealthReading>> recentReadings({int limit = 50});

  /// One entry per day, most recent last.
  Future<List<DailySummary>> dailySummary({int days = 7});

  /// How many readings are still waiting to reach the backend.
  Future<int> pendingSyncCount();

  /// Pushes every unsynced reading to the backend. Safe to call anytime —
  /// already-synced readings are skipped, and anything that fails to
  /// upload just stays unsynced for the next attempt.
  Future<void> syncPendingReadings();
}
