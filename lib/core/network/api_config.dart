import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const _port = 3000;

  /// Set this when running on a **physical device** (not a simulator or
  /// emulator) — your computer's current LAN IP, e.g. '192.168.1.23'. The
  /// phone and computer must be on the same Wi-Fi network. Leave null for
  /// simulator/emulator/web, where the platform-specific address below
  /// already resolves correctly.
  static const String? _physicalDeviceHostIp = null;

  /// Where the backend lives.
  ///
  /// The Android emulator can't reach the host machine through "localhost"
  /// — it has its own private loopback. 10.0.2.2 is the special address
  /// the Android emulator uses to mean "the computer running the emulator".
  /// iOS simulator, web, and desktop all share the host's network directly,
  /// so plain "localhost" works for them.
  static String get baseUrl {
    if (_physicalDeviceHostIp != null) return 'http://$_physicalDeviceHostIp:$_port';
    if (kIsWeb) return 'http://localhost:$_port';
    if (defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:$_port';
    return 'http://localhost:$_port';
  }
}
