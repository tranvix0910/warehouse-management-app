import 'package:flutter_dotenv/flutter_dotenv.dart';

// development
class ApiConstants {
  static String get baseUrl {
    return dotenv.env['BASE_URL'] ?? 'http://localhost:4000/api/v1';
  }
}

// production
// class ApiConstants {
//   static String get baseUrl {
//     return 'https://warehouse-management-backend-k2di.onrender.com/api/v1';
//   }
// }
