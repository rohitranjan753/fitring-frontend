import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  /// Where the NestJS backend lives.
  ///
  /// The Android emulator can't reach the host machine through "localhost"
  /// — it has its own private loopback. 10.0.2.2 is the special address
  /// the Android emulator uses to mean "the computer running the emulator".
  /// iOS simulator, web, and desktop all share the host's network directly,
  /// so plain "localhost" works for them.
  ///
  /// Running on a real phone instead of a simulator/emulator? Replace this
  /// with your computer's LAN IP (e.g. http://192.168.1.23:3000) — the
  /// phone and computer need to be on the same Wi-Fi network.
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    // Physical device on the same Wi-Fi as the dev machine — swap back to
    // 10.0.2.2 (Android emulator) / localhost (iOS simulator) if you switch
    // to running on a simulator/emulator instead.
    return 'http://192.168.1.4:3000';
  }

    /// phone and computer need to be on the same Wi-Fi network.
  // static String get baseUrl {
  //   if (kIsWeb) return 'http://localhost:3000';
  //   if (defaultTargetPlatform == TargetPlatform.android) {
  //     return 'http://10.0.2.2:3000';
  //   }
  //   return 'http://localhost:3000';
  //   // Physical device on the same Wi-Fi as the dev machine — swap back to
  //   // 10.0.2.2 (Android emulator) / localhost (iOS simulator) if you switch
  //   // to running on a simulator/emulator instead.
  //   return 'http://192.168.1.4:3000';
  // }
}
