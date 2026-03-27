import 'package:dio/dio.dart';
import 'api_client.dart';

class UserApi {
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await ApiClient.dio.get('/users/profile');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get profile');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? phone,
    String? address,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;

      final response = await ApiClient.dio.patch('/users/profile', data: data);
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update profile');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath, filename: 'avatar.jpg'),
      });

      final response = await ApiClient.dio.post(
        '/users/avatar',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to upload avatar');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await ApiClient.dio.patch(
        '/users/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'];
        
        if (statusCode == 400) {
          throw Exception(message ?? 'Invalid current password');
        } else if (statusCode == 401) {
          throw Exception('Current password is incorrect');
        }
        throw Exception(message ?? 'Failed to change password');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> deleteAccount({
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.delete(
        '/users/account',
        data: {'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to delete account');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to send reset email');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<List<Map<String, dynamic>>> getTeamMembers() async {
    try {
      final response = await ApiClient.dio.get('/users/team');
      final List<dynamic> data = response.data['data'] ?? [];
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to get team members');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> inviteTeamMember({
    required String email,
    required String role,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/users/team/invite',
        data: {
          'email': email,
          'role': role,
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to invite member');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> updateTeamMemberRole({
    required String userId,
    required String role,
  }) async {
    try {
      final response = await ApiClient.dio.patch(
        '/users/team/$userId/role',
        data: {'role': role},
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to update role');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> removeTeamMember({
    required String userId,
  }) async {
    try {
      final response = await ApiClient.dio.delete('/users/team/$userId');
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Failed to remove member');
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}
