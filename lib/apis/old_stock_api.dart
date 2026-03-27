import 'package:dio/dio.dart';
import 'api_client.dart';
import '../models/pagination_models.dart';

class SummaryOldStockApi {
  static Future<Map<String, dynamic>> getOldStockReport({
    PaginationParams? params,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/reports/old-stock',
        queryParameters: params?.toQueryParams(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Failed to load old stock report');
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;
        
        if (statusCode == 401) {
          throw Exception('Unauthorized. Please login again.');
        } else if (statusCode == 403) {
          throw Exception('Access forbidden. Insufficient permissions.');
        } else if (statusCode == 404) {
          throw Exception('Old stock report endpoint not found.');
        } else if (statusCode! >= 500) {
          throw Exception('Server error. Please try again later.');
        }
        
        throw Exception(errorData['message'] ?? 'Failed to get old stock report ($statusCode)');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> getOldStockPaginated({
    int page = 1,
    int limit = 20,
  }) async {
    return getOldStockReport(
      params: PaginationParams(page: page, limit: limit),
    );
  }
}
