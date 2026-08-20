import 'dart:async';
import 'dart:math';

import 'package:fitring_companion/features/wearable/models/health_reading.dart';
import 'package:fitring_companion/features/wearable/models/wearable_connection_state.dart';
import 'package:fitring_companion/features/wearable/repositories/wearable_repository.dart';
import 'package:fitring_companion/features/wearable/services/wearable_service.dart';

/// Owns the reconnection *policy* on top of the raw [WearableService]
/// primitives: exponential backoff, a max-attempt cutoff, and the
/// distinction between "user asked to disconnect" (stay disconnected) vs.
/// "the device dropped unexpectedly" (retry automatically). This is
/// deliberately service-agnostic — swapping [MockWearableService] for a
/// real BLE SDK implementation changes nothing here.
class WearableRepositoryImpl implements WearableRepository {
  WearableRepositoryImpl(this._wearableService) {
    _serviceSub = _wearableService.connectionState.listen(_onServiceStateChanged);
  }

  final WearableService _wearableService;
  late final StreamSubscription<WearableConnectionState> _serviceSub;

  final _stateController =
      StreamController<WearableConnectionState>.broadcast();

  static const _maxAttempts = 6;
  static const _baseBackoff = Duration(seconds: 1);
  static const _maxBackoff = Duration(seconds: 30);

  bool _userInitiatedDisconnect = false;
  int _attempt = 0;
  Timer? _retryTimer;

  @override
  Stream<WearableConnectionState> get connectionState =>
      _stateController.stream;

  @override
  Stream<HealthReading> get readings => _wearableService.readings;

  @override
  Future<void> connect() async {
    _userInitiatedDisconnect = false;
    _attempt = 0;
    _retryTimer?.cancel();
    await _wearableService.connect();
  }

  @override
  Future<void> disconnect() async {
    _userInitiatedDisconnect = true;
    _retryTimer?.cancel();
    await _wearableService.disconnect();
  }

  @override
  Future<void> reconnectManually() async {
    _attempt = 0;
    _retryTimer?.cancel();
    _userInitiatedDisconnect = false;
    await _wearableService.connect();
  }

  @override
  Future<int> batteryLevel() => _wearableService.batteryLevel();

  void _onServiceStateChanged(WearableConnectionState state) {
    switch (state) {
      case WearableConnected():
        _attempt = 0;
        _retryTimer?.cancel();
        _stateController.add(state);
      case WearableConnecting():
        _stateController.add(state);
      case WearableDisconnected():
        if (_userInitiatedDisconnect) {
          _stateController.add(state);
        } else {
          _beginAutoReconnect();
        }
      case WearableReconnecting():
      case WearableConnectionFailed():
        // The raw service never emits these itself — they're repository
        // policy states — but pass through defensively if it ever does.
        _stateController.add(state);
    }
  }

  void _beginAutoReconnect() {
    if (_attempt >= _maxAttempts) {
      _stateController.add(const WearableConnectionFailed());
      return;
    }

    _attempt += 1;
    _stateController.add(WearableReconnecting(_attempt));

    final delay = _backoffFor(_attempt);
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      unawaited(_wearableService.connect());
    });
  }

  Duration _backoffFor(int attempt) {
    final millis = _baseBackoff.inMilliseconds * (1 << (attempt - 1));
    final capped = min(millis, _maxBackoff.inMilliseconds);
    return Duration(milliseconds: capped);
  }

  Future<void> dispose() async {
    _retryTimer?.cancel();
    await _serviceSub.cancel();
    await _stateController.close();
  }
}
