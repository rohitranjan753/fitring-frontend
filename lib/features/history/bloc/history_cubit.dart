import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fitring_companion/features/health/repositories/health_repository.dart';
import 'package:fitring_companion/features/wearable/models/health_reading.dart';

class HistoryState extends Equatable {
  const HistoryState({
    this.isLoading = false,
    this.readings = const [],
    this.dailySummary = const [],
    this.pendingSyncCount = 0,
    this.errorMessage,
  });

  final bool isLoading;
  final List<HealthReading> readings;
  final List<DailySummary> dailySummary;
  final int pendingSyncCount;
  final String? errorMessage;

  HistoryState copyWith({
    bool? isLoading,
    List<HealthReading>? readings,
    List<DailySummary>? dailySummary,
    int? pendingSyncCount,
    String? errorMessage,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      readings: readings ?? this.readings,
      dailySummary: dailySummary ?? this.dailySummary,
      pendingSyncCount: pendingSyncCount ?? this.pendingSyncCount,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [isLoading, readings, dailySummary, pendingSyncCount, errorMessage];
}

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit(this._repository) : super(const HistoryState());

  final HealthRepository _repository;
  int _limit = 20;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final readings = await _repository.recentReadings(limit: _limit);
      final summary = await _repository.dailySummary(days: 7);
      final pending = await _repository.pendingSyncCount();
      emit(
        state.copyWith(
          isLoading: false,
          readings: readings,
          dailySummary: summary,
          pendingSyncCount: pending,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Could not load history.'));
    }
  }

  /// The PRD is explicit about never loading the whole table into the UI
  /// at once — this is the "Load more" escape hatch instead of a fixed cap.
  Future<void> loadMore() async {
    _limit += 20;
    await load();
  }

  Future<void> syncNow() async {
    await _repository.syncPendingReadings();
    await load();
  }
}
