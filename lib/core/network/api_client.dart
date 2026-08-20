import 'package:dio/dio.dart';
import 'package:fitring_companion/core/storage/session_storage.dart';
import 'package:fitring_companion/core/network/api_config.dart';

/// One shared Dio instance for the whole app. Every request automatically
/// gets the logged-in user's token attached — individual features never
/// have to think about auth headers themselves.
class ApiClient {
  ApiClient(this._session) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _session.readToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          // /auth/login already turns its own 401 into "wrong password" —
          // this is for every OTHER request, where a 401 means the saved
          // token expired or was revoked. Without this, screens would just
          // show a generic "could not load" error forever instead of
          // sending the user back to log in again.
          final isLoginRequest = error.requestOptions.path == '/auth/login';
          if (error.response?.statusCode == 401 && !isLoginRequest) {
            onUnauthorized?.call();
          }
          handler.next(error);
        },
      ),
    );
  }

  final SessionStorage _session;

  final Dio dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  /// Wired up in main.dart once AuthBloc exists — logs the user out and
  /// returns them to the login screen whenever a request comes back 401.
  void Function()? onUnauthorized;
}
