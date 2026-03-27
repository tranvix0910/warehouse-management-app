import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/token_storage.dart';

enum ActivityType {
  productCreated,
  productUpdated,
  productDeleted,
  stockIn,
  stockOut,
  customerCreated,
  supplierCreated,
  userLogin,
  userLogout,
  settingsChanged,
  reportExported,
  batchOperation,
}

class ActivityLog {
  final String id;
  final ActivityType type;
  final String title;
  final String description;
  final String? userId;
  final String? userName;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ActivityLog({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.userId,
    this.userName,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'title': title,
      'description': description,
      'userId': userId,
      'userName': userName,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      type: ActivityType.values[json['type']],
      title: json['title'],
      description: json['description'],
      userId: json['userId'],
      userName: json['userName'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      metadata: json['metadata'],
    );
  }

  IconData get icon {
    switch (type) {
      case ActivityType.productCreated:
        return Icons.add_box;
      case ActivityType.productUpdated:
        return Icons.edit;
      case ActivityType.productDeleted:
        return Icons.delete;
      case ActivityType.stockIn:
        return Icons.keyboard_arrow_down;
      case ActivityType.stockOut:
        return Icons.keyboard_arrow_up;
      case ActivityType.customerCreated:
        return Icons.person_add;
      case ActivityType.supplierCreated:
        return Icons.business;
      case ActivityType.userLogin:
        return Icons.login;
      case ActivityType.userLogout:
        return Icons.logout;
      case ActivityType.settingsChanged:
        return Icons.settings;
      case ActivityType.reportExported:
        return Icons.download;
      case ActivityType.batchOperation:
        return Icons.layers;
    }
  }

  Color get color {
    switch (type) {
      case ActivityType.productCreated:
      case ActivityType.customerCreated:
      case ActivityType.supplierCreated:
        return const Color(0xFF10B981);
      case ActivityType.productUpdated:
      case ActivityType.settingsChanged:
        return const Color(0xFF3B82F6);
      case ActivityType.productDeleted:
        return const Color(0xFFEF4444);
      case ActivityType.stockIn:
        return const Color(0xFF3B82F6);
      case ActivityType.stockOut:
        return const Color(0xFFF59E0B);
      case ActivityType.userLogin:
      case ActivityType.userLogout:
        return const Color(0xFF8B5CF6);
      case ActivityType.reportExported:
        return const Color(0xFF06B6D4);
      case ActivityType.batchOperation:
        return const Color(0xFFEC4899);
    }
  }

  String get typeLabel {
    switch (type) {
      case ActivityType.productCreated:
        return 'Product Created';
      case ActivityType.productUpdated:
        return 'Product Updated';
      case ActivityType.productDeleted:
        return 'Product Deleted';
      case ActivityType.stockIn:
        return 'Stock In';
      case ActivityType.stockOut:
        return 'Stock Out';
      case ActivityType.customerCreated:
        return 'Customer Added';
      case ActivityType.supplierCreated:
        return 'Supplier Added';
      case ActivityType.userLogin:
        return 'User Login';
      case ActivityType.userLogout:
        return 'User Logout';
      case ActivityType.settingsChanged:
        return 'Settings Changed';
      case ActivityType.reportExported:
        return 'Report Exported';
      case ActivityType.batchOperation:
        return 'Batch Operation';
    }
  }
}

class ActivityLogService {
  static final ActivityLogService _instance = ActivityLogService._internal();
  factory ActivityLogService() => _instance;
  ActivityLogService._internal();

  static const String _logsKey = 'activity_logs';
  static const int _maxLogs = 500;

  Future<List<ActivityLog>> getLogs({
    ActivityType? filterType,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getString(_logsKey);
    
    if (logsJson == null) return [];

    final List<dynamic> logsList = jsonDecode(logsJson);
    List<ActivityLog> logs = logsList.map((json) => ActivityLog.fromJson(json)).toList();

    if (filterType != null) {
      logs = logs.where((log) => log.type == filterType).toList();
    }

    if (startDate != null) {
      logs = logs.where((log) => log.timestamp.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      logs = logs.where((log) => log.timestamp.isBefore(endDate)).toList();
    }

    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    if (limit != null) {
      logs = logs.take(limit).toList();
    }

    return logs;
  }

  Future<void> addLog({
    required ActivityType type,
    required String title,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final user = await TokenStorage.getUser();
    
    final log = ActivityLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      title: title,
      description: description,
      userId: user?['id'],
      userName: user?['username'],
      timestamp: DateTime.now(),
      metadata: metadata,
    );

    final logsJson = prefs.getString(_logsKey);
    List<Map<String, dynamic>> logs = [];
    
    if (logsJson != null) {
      logs = List<Map<String, dynamic>>.from(jsonDecode(logsJson));
    }

    logs.insert(0, log.toJson());

    if (logs.length > _maxLogs) {
      logs = logs.take(_maxLogs).toList();
    }

    await prefs.setString(_logsKey, jsonEncode(logs));
  }

  Future<void> logProductCreated(String productName, String sku) async {
    await addLog(
      type: ActivityType.productCreated,
      title: 'Product Created',
      description: 'Created product "$productName" (SKU: $sku)',
      metadata: {'productName': productName, 'sku': sku},
    );
  }

  Future<void> logProductUpdated(String productName, String productId) async {
    await addLog(
      type: ActivityType.productUpdated,
      title: 'Product Updated',
      description: 'Updated product "$productName"',
      metadata: {'productName': productName, 'productId': productId},
    );
  }

  Future<void> logProductDeleted(String productName, String productId) async {
    await addLog(
      type: ActivityType.productDeleted,
      title: 'Product Deleted',
      description: 'Deleted product "$productName"',
      metadata: {'productName': productName, 'productId': productId},
    );
  }

  Future<void> logStockIn({
    required String supplierName,
    required int quantity,
    required int itemCount,
  }) async {
    await addLog(
      type: ActivityType.stockIn,
      title: 'Stock In',
      description: 'Received $quantity items ($itemCount products) from $supplierName',
      metadata: {
        'supplierName': supplierName,
        'quantity': quantity,
        'itemCount': itemCount,
      },
    );
  }

  Future<void> logStockOut({
    required String customerName,
    required int quantity,
    required int itemCount,
  }) async {
    await addLog(
      type: ActivityType.stockOut,
      title: 'Stock Out',
      description: 'Shipped $quantity items ($itemCount products) to $customerName',
      metadata: {
        'customerName': customerName,
        'quantity': quantity,
        'itemCount': itemCount,
      },
    );
  }

  Future<void> logBatchOperation({
    required String operation,
    required int count,
    String? details,
  }) async {
    await addLog(
      type: ActivityType.batchOperation,
      title: 'Batch Operation',
      description: '$operation: $count items${details != null ? ' - $details' : ''}',
      metadata: {'operation': operation, 'count': count},
    );
  }

  Future<void> logReportExported(String reportType, String format) async {
    await addLog(
      type: ActivityType.reportExported,
      title: 'Report Exported',
      description: 'Exported $reportType report as $format',
      metadata: {'reportType': reportType, 'format': format},
    );
  }

  Future<void> logUserLogin() async {
    await addLog(
      type: ActivityType.userLogin,
      title: 'User Login',
      description: 'User logged in',
    );
  }

  Future<void> logUserLogout() async {
    await addLog(
      type: ActivityType.userLogout,
      title: 'User Logout',
      description: 'User logged out',
    );
  }

  Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logsKey);
  }

  Future<Map<String, int>> getActivitySummary({int days = 7}) async {
    final logs = await getLogs(
      startDate: DateTime.now().subtract(Duration(days: days)),
    );

    final summary = <String, int>{};
    for (final log in logs) {
      final key = log.type.name;
      summary[key] = (summary[key] ?? 0) + 1;
    }

    return summary;
  }
}
