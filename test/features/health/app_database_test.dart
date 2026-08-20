import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fitring_companion/features/health/services/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests the exact mechanism the offline sync queue depends on: a unique
/// constraint on `clientUuid` plus an upsert insert, so a retried save of
/// the same reading never produces a duplicate row. This is what the
/// assignment calls "duplicate prevention" — tested here at the database
/// layer, since that's where the guarantee actually lives.
void main() {
  group('AppDatabase health readings — duplicate prevention', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() => db.close());

    // Mirrors HealthRepositoryImpl.saveReading() exactly — including the
    // `target:` fix, since `insertOnConflictUpdate` alone only resolves
    // conflicts on the primary key (`id`), never on `clientUuid`.
    Future<void> insertReading({required String clientUuid, required int heartRate}) {
      final companion = HealthReadingsTableCompanion.insert(
        clientUuid: clientUuid,
        deviceId: 'FITRING-001',
        heartRate: heartRate,
        spo2: 97,
        steps: 100,
        recordedAt: DateTime.utc(2026, 8, 20, 10),
      );
      return db
          .into(db.healthReadingsTable)
          .insert(
            companion,
            onConflict: DoUpdate((old) => companion, target: [db.healthReadingsTable.clientUuid]),
          );
    }

    test('saving the same clientUuid twice keeps exactly one row', () async {
      await insertReading(clientUuid: 'reading-1', heartRate: 70);
      await insertReading(clientUuid: 'reading-1', heartRate: 999); // a retried save

      final rows = await db.select(db.healthReadingsTable).get();

      expect(rows, hasLength(1));
      expect(rows.single.heartRate, 999); // last write wins, same as a real retry
    });

    test('different clientUuids produce separate rows', () async {
      await insertReading(clientUuid: 'reading-1', heartRate: 70);
      await insertReading(clientUuid: 'reading-2', heartRate: 72);

      final rows = await db.select(db.healthReadingsTable).get();

      expect(rows, hasLength(2));
    });

    test('newly inserted readings default to unsynced', () async {
      await insertReading(clientUuid: 'reading-1', heartRate: 70);

      final row = await db.select(db.healthReadingsTable).getSingle();

      expect(row.synced, isFalse);
    });
  });
}
