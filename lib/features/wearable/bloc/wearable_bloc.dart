import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fitring_companion/features/wearable/repositories/wearable_repository.dart';
import 'package:fitring_companion/features/wearable/bloc/wearable_event.dart';
import 'package:fitring_companion/features/wearable/bloc/wearable_state.dart';

class WearableBloc extends Bloc<WearableEvent, WearableState> {
  WearableBloc(this._repository) : super(const WearableState()) {
    on<WearableStarted>(_onStarted);
    on<WearableReconnectRequested>(_onReconnectRequested);
    on<WearableDisconnectRequested>(_onDisconnectRequested);
    on<WearableConnectionUpdated>(_onConnectionUpdated);
    on<WearableReadingArrived>(_onReadingArrived);
  }

  final WearableRepository _repository;
  StreamSubscription? _connectionSub;
  StreamSubscription? _readingsSub;

  Future<void> _onStarted(
    WearableStarted event,
    Emitter<WearableState> emit,
  ) async {
    await _connectionSub?.cancel();
    await _readingsSub?.cancel();

    _connectionSub = _repository.connectionState.listen(
      (state) => add(WearableConnectionUpdated(state)),
    );
    _readingsSub = _repository.readings.listen((reading) async {
      final battery = await _repository.batteryLevel();
      add(WearableReadingArrived(reading, battery));
    });

    await _repository.connect();
  }

  Future<void> _onReconnectRequested(
    WearableReconnectRequested event,
    Emitter<WearableState> emit,
  ) async {
    await _repository.reconnectManually();
  }

  Future<void> _onDisconnectRequested(
    WearableDisconnectRequested event,
    Emitter<WearableState> emit,
  ) async {
    await _repository.disconnect();
  }

  void _onConnectionUpdated(
    WearableConnectionUpdated event,
    Emitter<WearableState> emit,
  ) {
    emit(state.copyWith(connectionState: event.connectionState));
  }

  void _onReadingArrived(
    WearableReadingArrived event,
    Emitter<WearableState> emit,
  ) {
    emit(
      state.copyWith(
        latestReading: event.reading,
        batteryLevel: event.batteryLevel,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _connectionSub?.cancel();
    await _readingsSub?.cancel();
    return super.close();
  }
}
