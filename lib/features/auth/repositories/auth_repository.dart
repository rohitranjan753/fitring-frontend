import 'package:fitring_companion/features/auth/models/auth_user.dart';

abstract class AuthRepository {
  /// Throws [AuthException] on wrong credentials or a network problem.
  Future<AuthUser> login(String email, String password);

  Future<void> logout();

  /// Reads whoever is already logged in from local storage, if anyone —
  /// this is what lets the app skip the login screen on a fresh launch.
  Future<AuthUser?> currentUser();
}
