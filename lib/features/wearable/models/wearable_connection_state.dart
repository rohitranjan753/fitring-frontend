import 'package:equatable/equatable.dart';

/// Disconnected/Connecting/Connected are raw device primitives — any
/// [WearableService] implementation (mock or real SDK) emits only these.
/// Reconnecting/ConnectionFailed are reconnection *policy*, applied one
/// layer up by the repository, so the policy is identical regardless of
/// which service implementation is behind it.
sealed class WearableConnectionState extends Equatable {
  const WearableConnectionState();

  @override
  List<Object?> get props => [];
}

class WearableDisconnected extends WearableConnectionState {
  const WearableDisconnected();
}

class WearableConnecting extends WearableConnectionState {
  const WearableConnecting();
}

class WearableConnected extends WearableConnectionState {
  const WearableConnected();
}

class WearableReconnecting extends WearableConnectionState {
  const WearableReconnecting(this.attempt);

  final int attempt;

  @override
  List<Object?> get props => [attempt];
}

class WearableConnectionFailed extends WearableConnectionState {
  const WearableConnectionFailed();
}
