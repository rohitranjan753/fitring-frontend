import 'package:dio/dio.dart';

/// Talks to POST/GET /devices. Nothing else — no caching, no error
/// translation. That's HealthRepositoryImpl's job; this class only knows
/// HTTP, same split as AuthApi.
class DevicesApi {
  DevicesApi(this._dio);

  final Dio _dio;

  Future<List<DeviceDto>> listDevices() async {
    final response = await _dio.get<List<dynamic>>('/devices');
    return response.data!
        .map((json) => DeviceDto._fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<DeviceDto> registerDevice({required String externalId, required String name}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/devices',
      data: {'externalId': externalId, 'name': name},
    );
    return DeviceDto._fromJson(response.data!);
  }
}

class DeviceDto {
  const DeviceDto({required this.id, required this.externalId});

  /// The backend's own primary key — this, not [externalId], is what every
  /// other endpoint (health readings, etc.) expects as `deviceId`.
  final String id;
  final String externalId;

  factory DeviceDto._fromJson(Map<String, dynamic> json) {
    return DeviceDto(id: json['id'] as String, externalId: json['externalId'] as String);
  }
}
