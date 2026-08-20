import 'dart:async';
import 'dart:math';

import 'package:uuid/uuid.dart';

import 'package:fitring_companion/features/wearable/models/health_reading.dart';
import 'package:fitring_companion/features/wearable/models/wearable_connection_state.dart';
import 'package:fitring_companion/features/wearable/services/wearable_service.dart';

/// Simulates the FITRING-001 smart ring. Deliberately injects occasional
/// unexpected disconnects so [WearableRepository]'s reconnection policy has
/// real failures to recover from, not just the happy path.
class MockWearableService implements WearableService {
  MockWearableService({this.deviceId = 'FITRING-001', Random? random})
      : _random = random ?? Random();

  final String deviceId;
  final Random _random;
  final _uuid = const Uuid();

  final _connectionController =
      StreamController<WearableConnectionState>.broadcast();
  final _readingsController = StreamController<HealthReading>.broadcast();

  Timer? _readingTimer;

  int _heartRate = 72;
  int _spo2 = 97;
  int _steps = 6000;
  int _battery = 85;
  bool _connected = false;

  static const _tickInterval = Duration(seconds: 4);
  static const _unexpectedDropChance = 0.06;

  @override
  Stream<WearableConnectionState> get connectionState =>
      _connectionController.stream;

  @override
  Stream<HealthReading> get readings => _readingsController.stream;

  @override
  Future<void> connect() async {
    if (_connected) return;
    _connectionController.add(const WearableConnecting());
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _connected = true;
    _connectionController.add(const WearableConnected());
    _startEmitting();
  }

  @override
  Future<void> disconnect() async {
    _stopEmitting();
    _connected = false;
    _connectionController.add(const WearableDisconnected());
  }

  @override
  Future<int> batteryLevel() async => _battery;

  @override
  Future<void> dispose() async {
    _stopEmitting();
    await _connectionController.close();
    await _readingsController.close();
  }

  void _startEmitting() {
    _readingTimer?.cancel();
    _readingTimer = Timer.periodic(_tickInterval, (_) => _tick());
  }

  void _stopEmitting() {
    _readingTimer?.cancel();
    _readingTimer = null;
  }

  void _tick() {
    if (!_connected) return;

    if (_random.nextDouble() < _unexpectedDropChance) {
      _connected = false;
      _stopEmitting();
      _connectionController.add(const WearableDisconnected());
      return;
    }

    _heartRate = (_heartRate + _random.nextInt(5) - 2).clamp(58, 118);
    _spo2 = (_spo2 + _random.nextInt(3) - 1).clamp(93, 100);
    _steps += _random.nextInt(12);
    if (_battery > 1 && _random.nextDouble() < 0.15) _battery -= 1;

    _readingsController.add(
      HealthReading(
        id: _uuid.v4(),
        deviceId: deviceId,
        heartRate: _heartRate,
        spo2: _spo2,
        steps: _steps,
        recordedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
