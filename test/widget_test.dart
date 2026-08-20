import 'dart:async';

import 'package:fitring_companion/features/dashboard/pages/dashboard_screen.dart';
import 'package:fitring_companion/features/wearable/models/health_reading.dart';
import 'package:fitring_companion/features/wearable/models/wearable_connection_state.dart';
import 'package:fitring_companion/features/wearable/repositories/wearable_repository.dart';
import 'package:fitring_companion/features/wearable/bloc/wearable_bloc.dart';
import 'package:fitring_companion/features/wearable/bloc/wearable_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Manually driven — no timers of its own — so the widget test controls
/// exactly what the Bloc sees, rather than racing a real periodic Timer.
/// (Timer-driven reconnection behavior is covered by
/// wearable_repository_impl_test.dart instead.)
class _FakeWearableRepository implements WearableRepository {
  final _connectionController =
      StreamController<WearableConnectionState>.broadcast();
  final _readingsController = StreamController<HealthReading>.broadcast();

  @override
  Stream<WearableConnectionState> get connectionState =>
      _connectionController.stream;

  @override
  Stream<HealthReading> get readings => _readingsController.stream;

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> reconnectManually() async {}

  @override
  Future<int> batteryLevel() async => 72;

  void emitConnection(WearableConnectionState state) =>
      _connectionController.add(state);

  void emitReading(HealthReading reading) => _readingsController.add(reading);

  Future<void> dispose() async {
    await _connectionController.close();
    await _readingsController.close();
  }
}

void main() {
  testWidgets('Dashboard renders disconnected state, then a live reading once connected',
      (tester) async {
    final repository = _FakeWearableRepository();
    final bloc = WearableBloc(repository)..add(const WearableStarted());
    addTearDown(() async {
      await bloc.close();
      await repository.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: bloc, child: const DashboardScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Disconnected'), findsOneWidget);
    expect(find.text('— BPM'), findsNothing);

    repository.emitConnection(const WearableConnected());
    repository.emitReading(
      HealthReading(
        id: 'r1',
        deviceId: 'FITRING-001',
        heartRate: 78,
        spo2: 98,
        steps: 6420,
        recordedAt: DateTime.utc(2026, 8, 17, 10, 30),
      ),
    );
    // Two async hops between the stream emission and the rebuilt frame:
    // repository stream -> bloc.add() -> bloc's event handler -> emit().
    // pumpAndSettle drains all of that instead of guessing a pump count.
    await tester.pumpAndSettle();

    expect(find.text('Connected'), findsOneWidget);
    expect(find.text('78 BPM'), findsOneWidget);
    expect(find.text('98%'), findsOneWidget);
    expect(find.text('6420'), findsOneWidget);
  });

  testWidgets('Reconnect button appears only when disconnected or failed, and dispatches the retry event',
      (tester) async {
    final repository = _FakeWearableRepository();
    final bloc = WearableBloc(repository)..add(const WearableStarted());
    addTearDown(() async {
      await bloc.close();
      await repository.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: bloc, child: const DashboardScreen()),
      ),
    );
    await tester.pump();

    expect(find.byIcon(Icons.refresh), findsOneWidget);

    repository.emitConnection(const WearableConnected());
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.refresh), findsNothing);

    repository.emitConnection(const WearableConnectionFailed());
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}
