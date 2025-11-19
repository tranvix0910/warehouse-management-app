import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';

class UpdateProductApi {
  static Future<Map<String, dynamic>> updateProduct({
    required String productId,
    String? productName,
    String? sku,
    String? category,
    String? cost,
    String? price,
    String? quantity,
    String? ram,
    String? date,
    String? gpu,
    String? color,
    String? processor,
    File? image,
    XFile? xFileImage,
  }) async {
    try {
      // Create form data
      final formData = FormData();

      // Add fields only if they are provided
      if (productName != null) formData.fields.add(MapEntry('productName', productName));
      if (sku != null) formData.fields.add(MapEntry('SKU', sku));
      if (category != null) formData.fields.add(MapEntry('category', category));
      if (cost != null) formData.fields.add(MapEntry('cost', cost));
      if (price != null) formData.fields.add(MapEntry('price', price));
      if (quantity != null) formData.fields.add(MapEntry('quantity', quantity));
      if (ram != null) formData.fields.add(MapEntry('RAM', ram));
      if (date != null) formData.fields.add(MapEntry('date', date));
      if (gpu != null) formData.fields.add(MapEntry('GPU', gpu));
      if (color != null) formData.fields.add(MapEntry('color', color));
      if (processor != null) formData.fields.add(MapEntry('processor', processor));

      // Add image if provided
      if (image != null) {
        formData.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(image.path),
        ));
      } else if (xFileImage != null) {
        // Handle XFile for web and mobile
        if (kIsWeb) {
          final bytes = await xFileImage.readAsBytes();
          formData.files.add(MapEntry(
            'image',
            MultipartFile.fromBytes(bytes, filename: xFileImage.name),
          ));
        } else {
          formData.files.add(MapEntry(
            'image',
            await MultipartFile.fromFile(xFileImage.path),
          ));
        }
      }

      // Send the request
      final response = await ApiClient.dio.put(
        '/products/update/$productId',
        data: formData,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Failed to update product');
      
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final errorData = e.response!.data;
        
        if (statusCode == 401) {
          throw Exception('Unauthorized. Please login again.');
        } else if (statusCode == 403) {
          throw Exception('Access forbidden. Insufficient permissions.');
        } else if (statusCode == 400) {
          throw Exception(errorData['message'] ?? 'Invalid product data provided.');
        } else if (statusCode == 404) {
          throw Exception('Product not found.');
        } else if (statusCode! >= 500) {
          throw Exception('Server error. Please try again later.');
        }
        
        throw Exception(errorData['message'] ?? 'Failed to update product ($statusCode)');
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
