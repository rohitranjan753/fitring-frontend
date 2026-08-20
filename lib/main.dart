import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fitring_companion/core/di/injector.dart';
import 'package:fitring_companion/core/network/api_client.dart';
import 'package:fitring_companion/core/network/connectivity_cubit.dart';
import 'package:fitring_companion/core/theme/app_theme.dart';
import 'package:fitring_companion/features/auth/bloc/auth_bloc.dart';
import 'package:fitring_companion/features/auth/bloc/auth_event.dart';
import 'package:fitring_companion/features/auth/bloc/auth_state.dart';
import 'package:fitring_companion/features/auth/pages/auth_gate.dart';
import 'package:fitring_companion/features/history/bloc/history_cubit.dart';
import 'package:fitring_companion/features/shop/bloc/cart_cubit.dart';
import 'package:fitring_companion/features/shop/bloc/orders_cubit.dart';
import 'package:fitring_companion/features/shop/bloc/products_cubit.dart';
import 'package:fitring_companion/features/wearable/bloc/wearable_bloc.dart';
import 'package:fitring_companion/features/wearable/bloc/wearable_event.dart';

void main() {
  configureDependencies();
  // Any API call that comes back 401 (an expired/invalid token) logs the
  // user out, instead of every screen just showing a stuck "could not load"
  // error forever.
  sl<ApiClient>().onUnauthorized = () => sl<AuthBloc>().add(const AuthLogoutRequested());
  runApp(const FitRingApp());
}

class FitRingApp extends StatelessWidget {
  const FitRingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // All app-wide state lives in ONE provider list, above the app's single
    // Navigator. That matters: a provider placed *inside* a pushed screen
    // (e.g. inside HomeShell) would NOT be visible to screens reached via
    // Navigator.push, since pushed routes sit alongside HomeShell in the
    // navigator's stack, not nested inside it. Putting everything here,
    // above MaterialApp's home, sidesteps that entirely.
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()..add(const AuthStarted())),
        BlocProvider(create: (_) => sl<ConnectivityCubit>()),
        BlocProvider(create: (_) => sl<WearableBloc>()),
        BlocProvider(create: (_) => sl<HistoryCubit>()),
        BlocProvider(create: (_) => sl<ProductsCubit>()),
        BlocProvider(create: (_) => sl<CartCubit>()),
        BlocProvider(create: (_) => sl<OrdersCubit>()),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        // Covers both the logout button AND the automatic 401-triggered
        // logout in main() above — either way, a session that just ended
        // shouldn't leave the wearable connected and emitting in the
        // background. listenWhen restricts this to a real "was logged in,
        // now isn't" transition, not the initial pre-login state or a
        // failed login attempt (both of which are also AuthUnauthenticated).
        listenWhen: (previous, current) =>
            previous is AuthAuthenticated && current is AuthUnauthenticated,
        listener: (context, state) => context
            .read<WearableBloc>()
            .add(const WearableDisconnectRequested()),
        child: MaterialApp(
          title: 'FitRing Companion',
          theme: AppTheme.light(),
          home: const AuthGate(),
        ),
      ),
    );
  }
}
