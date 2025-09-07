// lib/config/api_constants.dart
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConstants {
  static String get baseUrl {
    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    // Nếu chạy Android Emulator → dùng 10.0.2.2
    // Nếu chạy iOS Simulator, Web, Desktop → dùng localhost
    return isAndroid ? 'http://10.0.2.2:4000/api/v1' : 'http://localhost:4000/api/v1';
  }
}