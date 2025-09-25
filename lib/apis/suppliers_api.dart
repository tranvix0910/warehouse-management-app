import 'package:dio/dio.dart';
import 'api_client.dart';

class GetAllSuppliersApi {
  static Future<Map<String, dynamic>> getAllSuppliers() async {
    try {
      final response = await ApiClient.dio.get('/suppliers');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Failed to load suppliers');
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;
        
        if (statusCode == 401) {
          throw Exception('Unauthorized. Please login again.');
        } else if (statusCode == 403) {
          throw Exception('Access forbidden. Insufficient permissions.');
        } else if (statusCode == 404) {
          throw Exception('Suppliers endpoint not found.');
        } else if (statusCode! >= 500) {
          throw Exception('Server error. Please try again later.');
        }
        
        throw Exception(errorData['message'] ?? 'Failed to get suppliers ($statusCode)');
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}


