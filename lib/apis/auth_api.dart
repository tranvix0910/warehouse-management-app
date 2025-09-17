import 'package:dio/dio.dart';
import 'api_client.dart';

class AuthApi {
  static Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
        options: Options(headers: {'Authorization': null}), // No auth needed for login
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Login failed');
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'Login failed (${e.response!.statusCode})');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/register',
        data: {
          'email': email,
          'username': username,
          'password': password,
        },
        options: Options(headers: {'Authorization': null}), // No auth needed for register
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Register failed');
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'Register failed (${e.response!.statusCode})');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/verify-otp',
        data: {'email': email, 'otp': otp},
        options: Options(headers: {'Authorization': null}), // No auth needed for OTP
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'OTP verification failed');
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'OTP verification failed (${e.response!.statusCode})');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> resendOtp({required String email}) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/resend-otp',
        data: {'email': email},
        options: Options(headers: {'Authorization': null}), // No auth needed for resend OTP
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Resend OTP failed');
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'Resend OTP failed (${e.response!.statusCode})');
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}
