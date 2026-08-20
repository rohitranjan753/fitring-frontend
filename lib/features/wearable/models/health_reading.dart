import 'package:equatable/equatable.dart';

class HealthReading extends Equatable {
  const HealthReading({
    required this.id,
    required this.deviceId,
    required this.heartRate,
    required this.spo2,
    required this.steps,
    required this.recordedAt,
  });

  /// Client-generated at creation time. Doubles as the idempotency key
  /// once this reading is queued for backend sync.
  final String id;
  final String deviceId;
  final int heartRate;
  final int spo2;
  final int steps;
  final DateTime recordedAt;

  @override
  List<Object?> get props => [id, deviceId, heartRate, spo2, steps, recordedAt];
}
