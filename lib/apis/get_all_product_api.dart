import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../utils/token_storage.dart';

class GetAllProductsApi {
  static Future<Map<String, dynamic>> getAllProducts() async {
    final accessToken = await TokenStorage.getAccessToken();
    
    if (accessToken == null) {
      throw Exception('No access token found. Please login again.');
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/products/all');
    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
        'accept': 'application/json',
      },
    );

    final Map<String, dynamic> body = _safeDecode(res.body);
    
    if (res.statusCode == 200 && body['success'] == true) {
      return body;
    }
    
    // Handle different error cases
    if (res.statusCode == 401) {
      throw Exception('Unauthorized. Please login again.');
    } else if (res.statusCode == 403) {
      throw Exception('Access forbidden. Insufficient permissions.');
    } else if (res.statusCode == 404) {
      throw Exception('Products endpoint not found.');
    } else if (res.statusCode >= 500) {
      throw Exception('Server error. Please try again later.');
    }
    
    throw Exception(body['message'] ?? 'Failed to get products (${res.statusCode})');
  }

  static Map<String, dynamic> _safeDecode(String source) {
    try {
      return jsonDecode(source) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}

