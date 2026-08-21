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

  int _heartRate = 72; // Default heart rate count
  int _spo2 = 97; // Default oxygen level count
  int _steps = 6000; // Default steps count
  int _battery = 85; // Default battery count
  bool _connected = false;

  // Default timer which will trigger update
  static const _tickInterval = Duration(seconds: 3);

  // As we are using random which generated value from 0 to 1
  // we have chosen 0.06 as a random number for droping
  static const _unexpectedDropChance = 0.06; 

  // Getter value for connection state stream
  @override
  Stream<WearableConnectionState> get connectionState =>
      _connectionController.stream;

  // Getter value for reading state stream
  @override
  Stream<HealthReading> get readings => _readingsController.stream;

  @override
  Future<void> connect() async {
    if (_connected) return;
    _connectionController.add(const WearableConnecting());
    await Future<void>.delayed(const Duration(seconds: 2));
    _connected = true;
    _connectionController.add(const WearableConnected());
    _startEmitting();
  }

  /// We will call below disconnect only when user logs out or api gets 401
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

    // If by chance the random generated number is less that 0.06
    // We will emit WearableDisconnected
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
