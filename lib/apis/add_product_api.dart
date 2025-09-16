import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_constants.dart';
import '../utils/token_storage.dart';

class AddProductApi {
  static Future<Map<String, dynamic>> addProduct({
    required String productName,
    required String sku,
    required String category,
    required String cost,
    required String price,
    required String quantity,
    required String ram,
    required String date,
    required String gpu,
    required String color,
    required String processor,
    String? barcode,
    File? image,
  }) async {
    final accessToken = await TokenStorage.getAccessToken();
    
    if (accessToken == null) {
      throw Exception('No access token found. Please login again.');
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/products/create');
    
    // Create multipart request
    var request = http.MultipartRequest('POST', uri);
    
    // Add headers
    request.headers.addAll({
      'accept': 'application/json',
      'Authorization': 'Bearer $accessToken',
    });
    
    // Add form fields
    request.fields.addAll({
      'productName': productName,
      'SKU': sku,
      'category': category,
      'cost': cost,
      'price': price,
      'quantity': quantity,
      'RAM': ram,
      'date': date,
      'GPU': gpu,
      'color': color,
      'processor': processor,
    });
    
    // Add barcode if provided
    if (barcode != null && barcode.isNotEmpty) {
      request.fields['barcode'] = barcode;
    }
    
    // Add image if provided
    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );
    } else {
      // Add empty image field as shown in the curl command
      request.fields['image'] = '';
    }

    try {
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      final Map<String, dynamic> body = _safeDecode(response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (body['success'] == true) {
          return body;
        }
      }
      
      // Handle different error cases
      if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('Access forbidden. Insufficient permissions.');
      } else if (response.statusCode == 400) {
        throw Exception(body['message'] ?? 'Invalid product data provided.');
      } else if (response.statusCode == 409) {
        throw Exception('Product with this SKU already exists.');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      }
      
      throw Exception(body['message'] ?? 'Failed to create product (${response.statusCode})');
      
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Map<String, dynamic> _safeDecode(String source) {
    try {
      return jsonDecode(source) as Map<String, dynamic>;
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}

