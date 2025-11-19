import 'package:dio/dio.dart';
import 'api_client.dart';

class SummaryOutStockApi {
  static Future<Map<String, dynamic>> getOutOfStockReport() async {
    try {
      final response = await ApiClient.dio.get('/reports/out-of-stock');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Failed to load out of stock report');
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;
        
        if (statusCode == 401) {
          throw Exception('Unauthorized. Please login again.');
        } else if (statusCode == 403) {
          throw Exception('Access forbidden. Insufficient permissions.');
        } else if (statusCode == 404) {
          throw Exception('Out of stock report endpoint not found.');
        } else if (statusCode! >= 500) {
          throw Exception('Server error. Please try again later.');
        }
        
        throw Exception(errorData['message'] ?? 'Failed to get out of stock report ($statusCode)');
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}
