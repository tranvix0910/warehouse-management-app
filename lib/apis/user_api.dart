import 'package:dio/dio.dart';
import 'api_client.dart';

class UserApi {
  static Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await ApiClient.dio.get('/users/info');

      print('getUserInfo response: ${response.data}'); // Debug log

      if (response.statusCode == 200 && response.data['success'] == true) {
        // Ensure all fields are properly typed
        final data = response.data['data'] as Map<String, dynamic>;
        
        // Convert any numeric strings to proper types if needed
        final cleanedData = <String, dynamic>{};
        data.forEach((key, value) {
          cleanedData[key] = value;
        });
        
        return {
          'success': response.data['success'],
          'message': response.data['message'],
          'data': cleanedData,
        };
      }
      throw Exception(response.data['message'] ?? 'Failed to get user info');
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'Failed to get user info (${e.response!.statusCode})');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('getUserInfo error: $e'); // Debug log
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateUserInfo({
    String? username,
    String? surName,
    String? birthday,
    String? company,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (username != null) data['username'] = username;
      if (surName != null) data['surName'] = surName;
      if (birthday != null) data['birthday'] = birthday;
      if (company != null) data['company'] = company;

      final response = await ApiClient.dio.put('/users/change-info', data: data);

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Failed to update user info');
    } on DioException catch (e) {
      if (e.response != null) {
        final errorData = e.response!.data;
        throw Exception(errorData['message'] ?? 'Failed to update user info (${e.response!.statusCode})');
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}
