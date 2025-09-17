import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';

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
    XFile? xFileImage,
  }) async {
    try {
      // Create form data
      final formData = FormData.fromMap({
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
        formData.fields.add(MapEntry('barcode', barcode));
      }

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
      final response = await ApiClient.dio.post(
        '/products/create',
        data: formData,
        options: Options(
          headers: {
            'accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Failed to create product');
      
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
        } else if (statusCode == 409) {
          throw Exception('Product with this SKU already exists.');
        } else if (statusCode! >= 500) {
          throw Exception('Server error. Please try again later.');
        }
        
        throw Exception(errorData['message'] ?? 'Failed to create product ($statusCode)');
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

