import 'package:dio/dio.dart';
import 'package:fitring_companion/features/auth/models/auth_user.dart';

class LoginResult {
  const LoginResult({required this.token, required this.user});

  final String token;
  final AuthUser user;
}

/// Talks to POST /auth/login. Nothing else — no error translation, no
/// storage. That's the repository's job; this class only knows HTTP.
class AuthApi {
  AuthApi(this._dio);

  final Dio _dio;

  Future<LoginResult> login(String email, String password) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = response.data!;
    final userJson = data['user'] as Map<String, dynamic>;
    return LoginResult(
      token: data['accessToken'] as String,
      user: AuthUser(id: userJson['id'] as String, email: userJson['email'] as String),
    );
  }
}
