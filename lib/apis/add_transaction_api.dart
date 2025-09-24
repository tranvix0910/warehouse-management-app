import 'package:dio/dio.dart';
import 'api_client.dart';

class AddTransactionApi {
  static Map<String, dynamic> _buildPayload({
    required String type,
    String? supplier,
    String? customer,
    String? note,
    required DateTime date,
    required List<Map<String, dynamic>> items,
  }) {
    // Normalize items to { product: <id>, quantity: <int> }
    final normalizedItems = items.map((raw) {
      final Object? id = raw['product'] ?? raw['productId'] ?? raw['_id'] ?? raw['id'];
      final Object? qty = raw['quantity'];
      return {
        'product': id,
        'quantity': qty,
      };
    }).toList();

    // Compute total quantity if not provided at top-level (server model may require it)
    final int totalQuantity = normalizedItems.fold<int>(0, (sum, it) {
      final dynamic q = it['quantity'];
      if (q is num) return sum + q.toInt();
      return sum;
    });

    return {
      'type': type,
      if (supplier != null && supplier.isNotEmpty) 'supplier': supplier,
      if (customer != null && customer.isNotEmpty) 'customer': customer,
      if (note != null && note.isNotEmpty) 'note': note,
      'date': date.toUtc().toIso8601String(),
      'items': normalizedItems,
      'quantity': totalQuantity,
    };
  }

  static Future<Map<String, dynamic>> createStockIn({
    required String supplier,
    String? note,
    required DateTime date,
    required List<Map<String, dynamic>> items,
  }) async {
    return _createTransaction(
      payload: _buildPayload(
        type: 'stock_in',
        supplier: supplier,
        note: note,
        date: date,
        items: items,
      ),
    );
  }

  static Future<Map<String, dynamic>> createStockOut({
    required String customer,
    String? note,
    required DateTime date,
    required List<Map<String, dynamic>> items,
  }) async {
    return _createTransaction(
      payload: _buildPayload(
        type: 'stock_out',
        customer: customer,
        note: note,
        date: date,
        items: items,
      ),
    );
  }

  static Future<Map<String, dynamic>> _createTransaction({
    required Map<String, dynamic> payload,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/transactions/create',
        data: payload,
        options: Options(
          headers: {
            'accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Failed to create transaction');
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;

        if (statusCode == 401) {
          throw Exception('Unauthorized. Please login again.');
        } else if (statusCode == 403) {
          throw Exception('Access forbidden. Insufficient permissions.');
        } else if (statusCode == 400) {
          throw Exception(errorData['message'] ?? 'Invalid transaction data provided.');
        } else if (statusCode == 404) {
          throw Exception('Transactions endpoint not found.');
        } else if (statusCode! >= 500) {
          throw Exception('Server error. Please try again later.');
        }

        throw Exception(errorData['message'] ?? 'Failed to create transaction ($statusCode)');
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

