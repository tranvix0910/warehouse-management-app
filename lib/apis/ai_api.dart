import 'package:dio/dio.dart';
import 'api_client.dart';

class GeminiSettingsResponse {
  final bool isConfigured;
  final String? apiKey;
  final DateTime? updatedAt;

  GeminiSettingsResponse({
    required this.isConfigured,
    this.apiKey,
    this.updatedAt,
  });

  factory GeminiSettingsResponse.fromJson(Map<String, dynamic> json) {
    return GeminiSettingsResponse(
      isConfigured: json['isConfigured'] ?? false,
      apiKey: json['apiKey'],
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }
}

class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class AIReportData {
  final String report;
  final Map<String, dynamic> rawData;
  final DateTime generatedAt;
  final String period;

  AIReportData({
    required this.report,
    required this.rawData,
    required this.generatedAt,
    required this.period,
  });

  factory AIReportData.fromJson(Map<String, dynamic> json) {
    return AIReportData(
      report: json['report'] ?? '',
      rawData: json['rawData'] ?? {},
      generatedAt: json['generatedAt'] != null 
          ? DateTime.parse(json['generatedAt']) 
          : DateTime.now(),
      period: json['period'] ?? 'weekly',
    );
  }

  int get totalTransactions => rawData['transactions']?['total'] ?? 0;
  int get stockInCount => rawData['transactions']?['stockIn'] ?? 0;
  int get stockOutCount => rawData['transactions']?['stockOut'] ?? 0;
  int get totalStockInQty => rawData['transactions']?['totalStockInQty'] ?? 0;
  int get totalStockOutQty => rawData['transactions']?['totalStockOutQty'] ?? 0;
  
  double get estimatedRevenue => (rawData['financial']?['estimatedRevenue'] ?? 0).toDouble();
  double get estimatedCost => (rawData['financial']?['estimatedCost'] ?? 0).toDouble();
  double get estimatedProfit => (rawData['financial']?['estimatedProfit'] ?? 0).toDouble();
  
  List<dynamic> get topProducts => rawData['topProducts'] ?? [];
  List<dynamic> get outOfStock => rawData['inventory']?['outOfStock'] ?? [];
  List<dynamic> get lowStock => rawData['inventory']?['lowStock'] ?? [];
  int get totalProducts => rawData['inventory']?['totalProducts'] ?? 0;
  
  String get dateRangeFrom => rawData['dateRange']?['from'] ?? '';
  String get dateRangeTo => rawData['dateRange']?['to'] ?? '';
  String get periodLabel => rawData['period'] ?? '';
}

class AIApi {
  static Future<GeminiSettingsResponse> getGeminiSettings() async {
    try {
      final response = await ApiClient.dio.get('/settings/gemini');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return GeminiSettingsResponse.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to get settings');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to get settings');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<GeminiSettingsResponse> saveGeminiApiKey(String apiKey) async {
    try {
      final response = await ApiClient.dio.put(
        '/settings/gemini',
        data: {'apiKey': apiKey},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return GeminiSettingsResponse.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to save API key');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Invalid API Key');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<void> deleteGeminiApiKey() async {
    try {
      final response = await ApiClient.dio.delete('/settings/gemini');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return;
      }
      throw Exception(response.data['message'] ?? 'Failed to delete API key');
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response!.data['message'] ?? 'Failed to delete');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<String> chat(String message) async {
    try {
      final response = await ApiClient.dio.post(
        '/ai/chat',
        data: {'message': message},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['answer'] ?? '';
      }
      throw Exception(response.data['message'] ?? 'Failed to get AI response');
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response!.data['message'] ?? 'AI service error';
        if (message.contains('chưa được cấu hình') || message.contains('not configured')) {
          throw ApiKeyNotConfiguredException(message);
        }
        throw Exception(message);
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  static Future<AIReportData> generateReport({required String period}) async {
    try {
      final response = await ApiClient.dio.get(
        '/ai/report',
        queryParameters: {'period': period},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return AIReportData.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to generate report');
    } on DioException catch (e) {
      if (e.response != null) {
        final message = e.response!.data['message'] ?? 'AI service error';
        if (message.contains('chưa được cấu hình') || message.contains('not configured')) {
          throw ApiKeyNotConfiguredException(message);
        }
        throw Exception(message);
      }
      throw Exception('Network error: ${e.message}');
    }
  }
}

class ApiKeyNotConfiguredException implements Exception {
  final String message;
  ApiKeyNotConfiguredException(this.message);
  
  @override
  String toString() => message;
}
