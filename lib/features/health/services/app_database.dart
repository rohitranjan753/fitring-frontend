import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

/// One row per health reading collected from the wearable.
///
/// `synced` doubles as our "sync queue": every row where `synced = false`
/// is exactly the set of readings still waiting to reach the backend, so
/// we don't need a separate queue table — one table does both jobs.
///
/// (Named `HealthReadingsTable`, not `HealthReadings`, so Drift's
/// generated row class `HealthReadingsTableData` doesn't collide with our
/// own `HealthReading` domain entity in the wearable feature.)
class HealthReadingsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get clientUuid => text().unique()();
  TextColumn get deviceId => text()();
  IntColumn get heartRate => integer()();
  IntColumn get spo2 => integer()();
  IntColumn get steps => integer()();
  DateTimeColumn get recordedAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [HealthReadingsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'fitring_companion'));

  /// Lets tests run against an in-memory database instead of a real file.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
}
