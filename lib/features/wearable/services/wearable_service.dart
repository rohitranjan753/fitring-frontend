import 'package:fitring_companion/features/wearable/models/health_reading.dart';
import 'package:fitring_companion/features/wearable/models/wearable_connection_state.dart';

/// The replaceable seam: everything above this interface (repository,
/// bloc, UI) behaves identically whether [connect]/[readings] are backed
/// by [MockWearableService] or a real vendor BLE SDK behind a platform
/// channel. See the PRD's "Wearable abstraction layer" section for the
/// real-SDK replacement plan (Pigeon, Android foreground service,
/// iOS CoreBluetooth state restoration).
abstract class WearableService {
  Stream<WearableConnectionState> get connectionState;

  Stream<HealthReading> get readings;

  Future<void> connect();

  Future<void> disconnect();

  Future<int> batteryLevel();

  Future<void> dispose();
}
