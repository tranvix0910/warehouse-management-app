import 'package:dio/dio.dart';
import 'api_client.dart';

class TransactionApi {
  static Future<List<dynamic>> getTransactions() async {
    try {
      final Response response = await ApiClient.dio.get('/transactions');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final body = response.data as Map<String, dynamic>;
        if (body['success'] == true && body['data'] is List) {
          return body['data'] as List<dynamic>;
        }
        throw Exception(body['message'] ?? 'Failed to fetch transactions');
      }
      throw Exception('Failed to fetch transactions (${response.statusCode})');
    } on DioException catch (e) {
      final message = e.response?.data is Map<String, dynamic>
          ? ((e.response!.data['message'])?.toString() ?? 'Network error')
          : (e.message ?? 'Network error');
      throw Exception(message);
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
