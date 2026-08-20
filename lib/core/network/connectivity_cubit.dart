import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Tracks whether the device has any network connection at all, for one
/// app-wide "you're offline" banner. Deliberately separate from
/// HealthRepository's pending-sync count in History — this is about the
/// connection itself, not about health-sync status specifically.
class ConnectivityCubit extends Cubit<bool> {
  ConnectivityCubit() : super(true) {
    _checkNow();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      emit(!results.contains(ConnectivityResult.none));
    });
  }

  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  Future<void> _checkNow() async {
    final result = await Connectivity().checkConnectivity();
    emit(!result.contains(ConnectivityResult.none));
  }

  @override
  Future<void> close() {
    _subscription.cancel();
    return super.close();
  }
}
