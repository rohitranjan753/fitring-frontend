import 'package:fitring_companion/features/wearable/models/health_reading.dart';
import 'package:fitring_companion/features/wearable/models/wearable_connection_state.dart';

abstract class WearableRepository {
  Stream<WearableConnectionState> get connectionState;

  Stream<HealthReading> get readings;

  Future<void> connect();

  Future<void> disconnect();

  /// User-triggered retry. Resets the automatic backoff counter — someone
  /// pressing "retry" should not inherit the automatic policy's cooldown.
  Future<void> reconnectManually();

  Future<int> batteryLevel();
}
