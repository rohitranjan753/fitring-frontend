import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the backend's own device UUID, keyed by the vendor externalId
/// (e.g. "FITRING-001") the mock wearable actually generates readings
/// under. Every reading synced to the backend must carry this UUID, not
/// the externalId — see HealthRepositoryImpl.syncPendingReadings.
class DeviceIdCache {
  DeviceIdCache(this._storage);

  final FlutterSecureStorage _storage;

  String _key(String externalId) => 'device_backend_id:$externalId';

  Future<String?> read(String externalId) => _storage.read(key: _key(externalId));

  Future<void> write(String externalId, String backendDeviceId) =>
      _storage.write(key: _key(externalId), value: backendDeviceId);
}
