import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/product_service.dart';
import '../models/transaction_models.dart';
import '../apis/transaction_api.dart';
import '../apis/api_client.dart';

class OfflineDatabase {
  static final OfflineDatabase _instance = OfflineDatabase._internal();
  factory OfflineDatabase() => _instance;
  OfflineDatabase._internal();

  static const String _productsKey = 'offline_products';
  static const String _transactionsKey = 'offline_transactions';
  static const String _customersKey = 'offline_customers';
  static const String _suppliersKey = 'offline_suppliers';
  static const String _pendingActionsKey = 'pending_sync_actions';
  static const String _lastSyncKey = 'last_sync_timestamp';

  bool? _lastOnlineStatus;

  Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection = connectivityResult.any((result) => 
        result == ConnectivityResult.mobile || 
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet
      );
      _lastOnlineStatus = hasConnection;
      return hasConnection;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return _lastOnlineStatus ?? false;
    }
  }

  Stream<bool> get onConnectivityChanged {
    return Connectivity().onConnectivityChanged.map((results) {
      final isOnline = results.any((result) => 
        result == ConnectivityResult.mobile || 
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet
      );
      _lastOnlineStatus = isOnline;
      return isOnline;
    });
  }

  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = products.map((p) => p.toJson()).toList();
      await prefs.setString(_productsKey, jsonEncode(jsonList));
      await _updateLastSync();
      debugPrint('Cached ${products.length} products to offline storage');
    } catch (e) {
      debugPrint('Error caching products: $e');
    }
  }

  Future<List<ProductModel>> getCachedProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_productsKey);
      if (jsonString == null || jsonString.isEmpty) return [];
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final products = jsonList.map((json) => ProductModel.fromJson(json)).toList();
      debugPrint('Retrieved ${products.length} cached products');
      return products;
    } catch (e) {
      debugPrint('Error getting cached products: $e');
      return [];
    }
  }

  Future<bool> hasCachedProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_productsKey);
    return jsonString != null && jsonString.isNotEmpty;
  }

  Future<void> cacheTransactions(List<Transaction> transactions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = transactions.map((t) => _transactionToJson(t)).toList();
      await prefs.setString(_transactionsKey, jsonEncode(jsonList));
      debugPrint('Cached ${transactions.length} transactions to offline storage');
    } catch (e) {
      debugPrint('Error caching transactions: $e');
    }
  }

  Future<List<Transaction>> getCachedTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_transactionsKey);
      if (jsonString == null || jsonString.isEmpty) return [];
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final transactions = jsonList.map((json) => Transaction.fromJson(json)).toList();
      debugPrint('Retrieved ${transactions.length} cached transactions');
      return transactions;
    } catch (e) {
      debugPrint('Error getting cached transactions: $e');
      return [];
    }
  }

  Future<bool> hasCachedTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_transactionsKey);
    return jsonString != null && jsonString.isNotEmpty;
  }

  Future<void> cacheCustomers(List<Map<String, dynamic>> customers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_customersKey, jsonEncode(customers));
    } catch (e) {
      debugPrint('Error caching customers: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCachedCustomers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_customersKey);
      if (jsonString == null || jsonString.isEmpty) return [];
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error getting cached customers: $e');
      return [];
    }
  }

  Future<void> cacheSuppliers(List<Map<String, dynamic>> suppliers) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_suppliersKey, jsonEncode(suppliers));
    } catch (e) {
      debugPrint('Error caching suppliers: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCachedSuppliers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_suppliersKey);
      if (jsonString == null || jsonString.isEmpty) return [];
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error getting cached suppliers: $e');
      return [];
    }
  }

  Future<void> addPendingAction(PendingAction action) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final actions = await getPendingActions();
      actions.add(action);
      
      final jsonList = actions.map((a) => a.toJson()).toList();
      await prefs.setString(_pendingActionsKey, jsonEncode(jsonList));
      debugPrint('Added pending action: ${action.type}');
    } catch (e) {
      debugPrint('Error adding pending action: $e');
    }
  }

  Future<List<PendingAction>> getPendingActions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_pendingActionsKey);
      if (jsonString == null || jsonString.isEmpty) return [];
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => PendingAction.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error getting pending actions: $e');
      return [];
    }
  }

  Future<void> clearPendingActions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingActionsKey);
  }

  Future<void> removePendingAction(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final actions = await getPendingActions();
      actions.removeWhere((a) => a.id == id);
      
      final jsonList = actions.map((a) => a.toJson()).toList();
      await prefs.setString(_pendingActionsKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error removing pending action: $e');
    }
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastSyncKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<void> _updateLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<SyncResult> syncWithServer() async {
    if (!await isOnline()) {
      return SyncResult(
        success: false,
        message: 'No internet connection',
        syncedCount: 0,
        failedCount: 0,
      );
    }

    final pendingActions = await getPendingActions();
    int syncedCount = 0;
    int failedCount = 0;
    final List<String> errors = [];

    for (final action in pendingActions) {
      try {
        await _executePendingAction(action);
        await removePendingAction(action.id);
        syncedCount++;
        debugPrint('Synced action: ${action.type}');
      } catch (e) {
        failedCount++;
        errors.add('${action.type}: ${e.toString()}');
        debugPrint('Failed to sync action ${action.type}: $e');
      }
    }

    try {
      final products = await ProductService.instance.getProducts(forceRefresh: true);
      await cacheProducts(products);
      
      final transactionsResponse = await GetAllTransactionsApi.getAllTransactions();
      final transactionResponse = TransactionResponse.fromJson(transactionsResponse);
      if (transactionResponse.success) {
        await cacheTransactions(transactionResponse.data);
      }
    } catch (e) {
      errors.add('Failed to refresh cache: ${e.toString()}');
      debugPrint('Failed to refresh cache: $e');
    }

    return SyncResult(
      success: failedCount == 0,
      message: failedCount == 0 
          ? 'Sync completed successfully ($syncedCount actions synced)' 
          : 'Sync completed with $failedCount errors',
      syncedCount: syncedCount,
      failedCount: failedCount,
      errors: errors,
    );
  }

  Future<void> _executePendingAction(PendingAction action) async {
    switch (action.type) {
      case PendingActionType.createProduct:
        await ApiClient.dio.post('/products', data: action.data);
        break;
      case PendingActionType.updateProduct:
        final productId = action.data['_id'] ?? action.data['id'];
        await ApiClient.dio.put('/products/$productId', data: action.data);
        break;
      case PendingActionType.deleteProduct:
        final productId = action.data['_id'] ?? action.data['id'];
        await ApiClient.dio.delete('/products/$productId');
        break;
      case PendingActionType.createTransaction:
        await ApiClient.dio.post('/transactions', data: action.data);
        break;
      case PendingActionType.createCustomer:
        await ApiClient.dio.post('/customers', data: action.data);
        break;
      case PendingActionType.createSupplier:
        await ApiClient.dio.post('/suppliers', data: action.data);
        break;
    }
  }

  Map<String, dynamic> _transactionToJson(Transaction t) {
    return {
      '_id': t.id,
      'type': t.type,
      'quantity': t.quantity,
      'items': t.items.map((item) {
        return {
          '_id': item.id,
          'product': {
            '_id': item.product.id,
            'productName': item.product.productName,
            'cost': item.product.cost,
            'price': item.product.price,
            'SKU': item.product.sku,
            'category': item.product.category,
            'RAM': item.product.ram,
            'date': item.product.date,
            'GPU': item.product.gpu,
            'color': item.product.color,
            'processor': item.product.processor,
            'quantity': item.product.quantity,
            'image': item.product.image,
          },
          'quantity': item.quantity,
        };
      }).toList(),
      'supplier': t.supplier,
      'customer': t.customer,
      'note': t.note,
      'date': t.date,
      'createdAt': t.createdAt,
      'updatedAt': t.updatedAt,
    };
  }

  Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_productsKey);
    await prefs.remove(_transactionsKey);
    await prefs.remove(_customersKey);
    await prefs.remove(_suppliersKey);
    await prefs.remove(_lastSyncKey);
    await prefs.remove(_pendingActionsKey);
    debugPrint('Cleared all offline cache');
  }
}

enum PendingActionType {
  createProduct,
  updateProduct,
  deleteProduct,
  createTransaction,
  createCustomer,
  createSupplier,
}

class PendingAction {
  final String id;
  final PendingActionType type;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  PendingAction({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'data': data,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory PendingAction.fromJson(Map<String, dynamic> json) {
    return PendingAction(
      id: json['id'],
      type: PendingActionType.values[json['type']],
      data: json['data'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    );
  }
}

class SyncResult {
  final bool success;
  final String message;
  final int syncedCount;
  final int failedCount;
  final List<String> errors;

  SyncResult({
    required this.success,
    required this.message,
    required this.syncedCount,
    required this.failedCount,
    this.errors = const [],
  });
}
