import 'package:dio/dio.dart';
import 'api_client.dart';

class AddSupplierApi {
  static Future<Map<String, dynamic>> addSupplier({
    required String name,
    required String email,
    required String address,
    String? notes,
    required int phone,
  }) async {
    try {
      final payload = {
        'name': name,
        'email': email,
        'address': address,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'phone': phone,
      };

      final response = await ApiClient.dio.post(
        '/suppliers',
        data: payload,
        options: Options(
          headers: {
            'accept': 'application/json',
          },
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) && response.data['success'] == true) {
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Failed to create supplier');
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;

        if (statusCode == 401) {
          throw Exception('Unauthorized. Please login again.');
        } else if (statusCode == 403) {
          throw Exception('Access forbidden. Insufficient permissions.');
        } else if (statusCode == 400) {
          throw Exception(errorData['message'] ?? 'Invalid supplier data provided.');
        } else if (statusCode == 404) {
          throw Exception('Suppliers endpoint not found.');
        } else if (statusCode == 409) {
          throw Exception(errorData['message'] ?? 'Supplier already exists.');
        } else if (statusCode! >= 500) {
          throw Exception('Server error. Please try again later.');
        }

        throw Exception(errorData['message'] ?? 'Failed to create supplier ($statusCode)');
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


