import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitring_companion/features/home/home_shell.dart';
import 'package:fitring_companion/features/auth/bloc/auth_bloc.dart';
import 'package:fitring_companion/features/auth/bloc/auth_state.dart';
import 'package:fitring_companion/features/auth/pages/login_screen.dart';

/// Decides which screen to show based on login state: a brief splash while
/// checking for an existing session, the login form, or the main app.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return switch (state) {
          AuthInitial() => const _SplashScreen(),
          AuthAuthenticated() => const HomeShell(),
          AuthLoading() || AuthUnauthenticated() => const LoginScreen(),
        };
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
