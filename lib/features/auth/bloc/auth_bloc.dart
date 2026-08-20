import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitring_companion/core/errors/auth_exception.dart';
import 'package:fitring_companion/features/auth/repositories/auth_repository.dart';
import 'package:fitring_companion/features/auth/bloc/auth_event.dart';
import 'package:fitring_companion/features/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._repository) : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _repository;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final user = await _repository.currentUser();
    emit(user != null ? AuthAuthenticated(user) : const AuthUnauthenticated());
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _repository.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthUnauthenticated(errorMessage: e.message));
    }
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _repository.logout();
    emit(const AuthUnauthenticated());
  }
}
