import 'package:dio/dio.dart';
import 'api_client.dart';

class AddFavoriteCustomerApi {
  static Future<Map<String, dynamic>> markAsFavorite({
    required String customerId,
  }) async {
    try {
      final response = await ApiClient.dio.put(
        '/customers/favorite/$customerId',
        options: Options(
          headers: {
            'accept': 'application/json',
          },
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data['success'] == true) {
        return response.data;
      }
      throw Exception(
          response.data['message'] ?? 'Failed to update favorite customer');
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;

        if (statusCode == 401) {
          throw Exception('Unauthorized. Please login again.');
        } else if (statusCode == 403) {
          throw Exception('Access forbidden. Insufficient permissions.');
        } else if (statusCode == 404) {
          throw Exception('Customer not found.');
        } else if (statusCode == 400) {
          throw Exception(errorData['message'] ??
              'Invalid customer id provided.');
        } else if (statusCode! >= 500) {
          throw Exception('Server error. Please try again later.');
        }

        throw Exception(errorData['message'] ??
            'Failed to update favorite customer ($statusCode)');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
