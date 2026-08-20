import 'package:equatable/equatable.dart';

import 'package:fitring_companion/features/wearable/models/health_reading.dart';
import 'package:fitring_companion/features/wearable/models/wearable_connection_state.dart';

sealed class WearableEvent extends Equatable {
  const WearableEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched once when the dashboard first mounts.
class WearableStarted extends WearableEvent {
  const WearableStarted();
}

class WearableReconnectRequested extends WearableEvent {
  const WearableReconnectRequested();
}

class WearableDisconnectRequested extends WearableEvent {
  const WearableDisconnectRequested();
}

/// Internal — dispatched by the bloc's own stream subscriptions, never
/// added directly from the UI.
class WearableConnectionUpdated extends WearableEvent {
  const WearableConnectionUpdated(this.connectionState);

  final WearableConnectionState connectionState;

  @override
  List<Object?> get props => [connectionState];
}

class WearableReadingArrived extends WearableEvent {
  const WearableReadingArrived(this.reading, this.batteryLevel);

  final HealthReading reading;
  final int batteryLevel;

  @override
  List<Object?> get props => [reading, batteryLevel];
}
