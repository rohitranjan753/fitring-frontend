import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fitring_companion/features/auth/models/auth_user.dart';

/// Remembers who's logged in so the app doesn't force a fresh login every
/// time it's reopened. Uses the platform's secure storage (Android
/// Keystore / iOS Keychain) instead of plain shared-preferences, because a
/// login token is a credential, not just a UI setting.
class SessionStorage {
  SessionStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _userEmailKey = 'auth_user_email';

  Future<void> save({required String token, required AuthUser user}) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: user.id);
    await _storage.write(key: _userEmailKey, value: user.email);
  }

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<AuthUser?> readUser() async {
    final id = await _storage.read(key: _userIdKey);
    final email = await _storage.read(key: _userEmailKey);
    if (id == null || email == null) return null;
    return AuthUser(id: id, email: email);
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _userEmailKey);
  }
}
