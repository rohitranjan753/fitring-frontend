import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:fitring_companion/features/wearable/repositories/wearable_repository_impl.dart';
import 'package:fitring_companion/features/wearable/models/health_reading.dart';
import 'package:fitring_companion/features/wearable/models/wearable_connection_state.dart';
import 'package:fitring_companion/features/wearable/services/wearable_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// A hand-driven fake — no timers of its own — so the test controls exactly
/// when the "device" connects, drops, or stays silent, and can assert on
/// the repository's backoff policy deterministically under [fakeAsync].
class _FakeWearableService implements WearableService {
  final _connectionController =
      StreamController<WearableConnectionState>.broadcast();
  final _readingsController = StreamController<HealthReading>.broadcast();

  int connectCallCount = 0;

  @override
  Stream<WearableConnectionState> get connectionState =>
      _connectionController.stream;

  @override
  Stream<HealthReading> get readings => _readingsController.stream;

  @override
  Future<void> connect() async {
    connectCallCount++;
  }

  @override
  Future<void> disconnect() async {
    // Mirrors the real MockWearableService contract: disconnect() reports
    // Disconnected on the connection stream, same as an unexpected drop —
    // it's the repository's job to tell the two apart.
    emit(const WearableDisconnected());
  }

  @override
  Future<int> batteryLevel() async => 100;

  @override
  Future<void> dispose() async {
    await _connectionController.close();
    await _readingsController.close();
  }

  void emit(WearableConnectionState state) => _connectionController.add(state);
}

void main() {
  group('WearableRepositoryImpl reconnection policy', () {
    test('unexpected disconnect triggers auto-reconnect with exponential backoff', () {
      fakeAsync((async) {
        final service = _FakeWearableService();
        final repo = WearableRepositoryImpl(service);
        final states = <WearableConnectionState>[];
        repo.connectionState.listen(states.add);

        // Simulate an unexpected drop (never called repo.disconnect()).
        service.emit(const WearableDisconnected());
        async.flushMicrotasks();

        expect(states.last, isA<WearableReconnecting>());
        expect((states.last as WearableReconnecting).attempt, 1);
        expect(service.connectCallCount, 0, reason: 'first attempt waits out the backoff');

        async.elapse(const Duration(seconds: 1));
        expect(service.connectCallCount, 1, reason: 'attempt 1 fires after 1s');

        // Still not connected -> drops again -> attempt 2 waits 2s.
        service.emit(const WearableDisconnected());
        async.flushMicrotasks();
        expect((states.last as WearableReconnecting).attempt, 2);

        async.elapse(const Duration(milliseconds: 1999));
        expect(service.connectCallCount, 1, reason: 'not yet at the 2s mark');
        async.elapse(const Duration(milliseconds: 1));
        expect(service.connectCallCount, 2);

        repo.dispose();
      });
    });

    test('backoff is capped at 30s and gives up after the max attempt count', () {
      fakeAsync((async) {
        final service = _FakeWearableService();
        final repo = WearableRepositoryImpl(service);
        final states = <WearableConnectionState>[];
        repo.connectionState.listen(states.add);

        // Drive 6 consecutive unexpected drops — each one only after the
        // previous backoff has actually elapsed, matching real behavior.
        for (var i = 1; i <= 6; i++) {
          service.emit(const WearableDisconnected());
          async.flushMicrotasks();
          expect((states.last as WearableReconnecting).attempt, i);
          async.elapse(const Duration(seconds: 30));
        }

        // A 7th drop should exceed the max-attempt cutoff.
        service.emit(const WearableDisconnected());
        async.flushMicrotasks();
        expect(states.last, isA<WearableConnectionFailed>());

        repo.dispose();
      });
    });

    test('a successful connect resets the attempt counter', () {
      fakeAsync((async) {
        final service = _FakeWearableService();
        final repo = WearableRepositoryImpl(service);
        final states = <WearableConnectionState>[];
        repo.connectionState.listen(states.add);

        service.emit(const WearableDisconnected());
        async.flushMicrotasks();
        expect((states.last as WearableReconnecting).attempt, 1);

        service.emit(const WearableConnected());
        async.flushMicrotasks();

        // Next unexpected drop should restart from attempt 1, not continue
        // climbing the backoff curve.
        service.emit(const WearableDisconnected());
        async.flushMicrotasks();
        expect((states.last as WearableReconnecting).attempt, 1);

        repo.dispose();
      });
    });

    test('user-initiated disconnect does not trigger auto-reconnect', () async {
      final service = _FakeWearableService();
      final repo = WearableRepositoryImpl(service);
      final states = <WearableConnectionState>[];
      repo.connectionState.listen(states.add);

      await repo.disconnect();
      await Future<void>.delayed(Duration.zero);

      expect(states, [isA<WearableDisconnected>()]);
      expect(service.connectCallCount, 0);

      await repo.dispose();
    });

    test('manual reconnect resets the backoff counter', () {
      fakeAsync((async) {
        final service = _FakeWearableService();
        final repo = WearableRepositoryImpl(service);
        final states = <WearableConnectionState>[];
        repo.connectionState.listen(states.add);

        // Climb to attempt 3.
        for (var i = 1; i <= 3; i++) {
          service.emit(const WearableDisconnected());
          async.flushMicrotasks();
          async.elapse(const Duration(seconds: 30));
        }
        expect(service.connectCallCount, 3);

        // Manual retry should call connect() immediately, bypassing backoff.
        unawaited(repo.reconnectManually());
        async.flushMicrotasks();
        expect(service.connectCallCount, 4);

        // A subsequent unexpected drop should restart from attempt 1.
        service.emit(const WearableDisconnected());
        async.flushMicrotasks();
        expect((states.last as WearableReconnecting).attempt, 1);

        repo.dispose();
      });
    });
  });
}
