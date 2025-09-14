import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';

class AuthApi {
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/auth/login');
    final res = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final Map<String, dynamic> body = _safeDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      return body;
    }
    throw Exception(body['message'] ?? 'Login failed (${res.statusCode})');
  }

  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/auth/register');
    final res = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
      }),
    );

    final Map<String, dynamic> body = _safeDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      return body;
    }
    throw Exception(body['message'] ?? 'Register failed (${res.statusCode})');
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/auth/verify-otp');
    final res = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    final Map<String, dynamic> body = _safeDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      return body;
    }
    throw Exception(
      body['message'] ?? 'OTP verification failed (${res.statusCode})',
    );
  }

  static Future<Map<String, dynamic>> resendOtp({required String email}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/auth/resend-otp');
    final res = await http.post(
      uri,
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final Map<String, dynamic> body = _safeDecode(res.body);
    if (res.statusCode == 200 && body['success'] == true) {
      return body;
    }
    throw Exception(body['message'] ?? 'Resend OTP failed (${res.statusCode})');
  }

  static Map<String, dynamic> _safeDecode(String source) {
    try {
      return jsonDecode(source) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}
