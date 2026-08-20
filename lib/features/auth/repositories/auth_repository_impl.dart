import 'package:dio/dio.dart';
import 'package:fitring_companion/core/storage/session_storage.dart';
import 'package:fitring_companion/core/errors/auth_exception.dart';
import 'package:fitring_companion/features/auth/models/auth_user.dart';
import 'package:fitring_companion/features/auth/repositories/auth_repository.dart';
import 'package:fitring_companion/features/auth/services/auth_api.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api, this._session);

  final AuthApi _api;
  final SessionStorage _session;

  @override
  Future<AuthUser> login(String email, String password) async {
    try {
      final result = await _api.login(email, password);
      await _session.save(token: result.token, user: result.user);
      return result.user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthException('Incorrect email or password.');
      }
      throw const AuthException('Could not reach the server. Check your connection and try again.');
    }
  }

  @override
  Future<void> logout() => _session.clear();

  @override
  Future<AuthUser?> currentUser() => _session.readUser();
}
