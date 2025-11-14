import 'package:dio/dio.dart';
import 'api_client.dart';

class DeleteProductApi {
  static Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      final response = await ApiClient.dio.delete(
        '/products/delete/$productId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Failed to delete product');
      
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;
        
        if (statusCode == 401) {
          throw Exception('Unauthorized. Please login again.');
        } else if (statusCode == 403) {
          throw Exception('Access forbidden. Insufficient permissions.');
        } else if (statusCode == 400) {
          // Product is referenced in transactions
          final transactionCount = errorData['transactionCount'] ?? 0;
          throw Exception(
            errorData['message'] ?? 
            'Cannot delete product. It is referenced in $transactionCount transaction(s)'
          );
        } else if (statusCode == 404) {
          throw Exception('Product not found.');
        } else if (statusCode! >= 500) {
          throw Exception('Server error. Please try again later.');
        }
        
        throw Exception(errorData['message'] ?? 'Failed to delete product ($statusCode)');
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
