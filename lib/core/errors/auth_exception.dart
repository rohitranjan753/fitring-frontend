/// A login failure, already translated into a message safe to show the user.
class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}
