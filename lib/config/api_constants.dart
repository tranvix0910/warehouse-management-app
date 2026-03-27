import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get baseUrl {
    return dotenv.env['BASE_URL'] ?? 'http://localhost:4000/api/v1';
  }
}
