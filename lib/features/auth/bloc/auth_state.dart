import 'package:equatable/equatable.dart';
import 'package:fitring_companion/features/auth/models/auth_user.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Still checking local storage for an existing session — shown briefly on launch.
class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);

  final AuthUser user;

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated({this.errorMessage});

  final String? errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}
