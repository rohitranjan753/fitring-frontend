import 'package:equatable/equatable.dart';

import 'package:fitring_companion/features/wearable/models/health_reading.dart';
import 'package:fitring_companion/features/wearable/models/wearable_connection_state.dart';

class WearableState extends Equatable {
  const WearableState({
    this.connectionState = const WearableDisconnected(),
    this.latestReading,
    this.batteryLevel,
  });

  final WearableConnectionState connectionState;

  /// Kept even while disconnected — the dashboard greys these out rather
  /// than blanking them, per the error-handling design in the PRD.
  final HealthReading? latestReading;
  final int? batteryLevel;

  WearableState copyWith({
    WearableConnectionState? connectionState,
    HealthReading? latestReading,
    int? batteryLevel,
  }) {
    return WearableState(
      connectionState: connectionState ?? this.connectionState,
      latestReading: latestReading ?? this.latestReading,
      batteryLevel: batteryLevel ?? this.batteryLevel,
    );
  }

  @override
  List<Object?> get props => [connectionState, latestReading, batteryLevel];
}
