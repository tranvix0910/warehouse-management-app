import 'package:flutter/foundation.dart';
import '../apis/product_api.dart';
import '../models/pagination_models.dart';
import 'offline_database.dart';

class ProductModel {
  final String id;
  final String name;
  final String sku;
  final String cost;
  final String price;
  final int quantity;
  final String image;
  final String category;
  final String ram;
  final String date;
  final String gpu;
  final String color;
  final String processor;
  final String zone;

  ProductModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.cost,
    required this.price,
    required this.quantity,
    required this.image,
    required this.category,
    required this.ram,
    required this.date,
    required this.gpu,
    required this.color,
    required this.processor,
    this.zone = 'Unassigned',
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      name: json['productName'] ?? '',
      sku: json['SKU'] ?? '',
      cost: json['cost']?.toString() ?? '0',
      price: json['price']?.toString() ?? '0',
      quantity: json['quantity'] ?? 0,
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      ram: json['RAM'] ?? '',
      date: json['date'] ?? '',
      gpu: json['GPU'] ?? '',
      color: json['color'] ?? '',
      processor: json['processor'] ?? '',
      zone: json['zone'] ?? 'Unassigned',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productName': name,
      'SKU': sku,
      'cost': cost,
      'price': price,
      'quantity': quantity,
      'image': image,
      'category': category,
      'RAM': ram,
      'date': date,
      'GPU': gpu,
      'color': color,
      'processor': processor,
      'zone': zone,
    };
  }
}

class ProductService {
  static ProductService? _instance;
  static ProductService get instance => _instance ??= ProductService._();
  
  ProductService._();

  final _offlineDb = OfflineDatabase();
  List<ProductModel>? _cachedProducts;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  Future<List<ProductModel>> getProducts({bool forceRefresh = false}) async {
    // Return RAM cached data if valid and not forcing refresh
    if (!forceRefresh && 
        _cachedProducts != null && 
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration) {
      return _cachedProducts!;
    }

    final isOnline = await _offlineDb.isOnline();

    if (isOnline) {
      try {
        final response = await GetAllProductsApi.getAllProducts();
        final List<dynamic> productsData = response['data'] ?? [];
        
        _cachedProducts = productsData.map((json) => ProductModel.fromJson(json)).toList();
        _lastFetchTime = DateTime.now();
        
        // Cache to offline storage
        await _offlineDb.cacheProducts(_cachedProducts!);
        
        return _cachedProducts!;
      } catch (e) {
        debugPrint('API error, trying offline cache: $e');
        // If API fails, try offline cache
        return await _getOfflineProducts();
      }
    } else {
      // Offline mode - get cached data
      debugPrint('Offline mode - loading cached products');
      return await _getOfflineProducts();
    }
  }

  Future<List<ProductModel>> _getOfflineProducts() async {
    // Try RAM cache first
    if (_cachedProducts != null) {
      return _cachedProducts!;
    }
    
    // Then try offline storage
    final offlineProducts = await _offlineDb.getCachedProducts();
    if (offlineProducts.isNotEmpty) {
      _cachedProducts = offlineProducts;
      return offlineProducts;
    }
    
    throw Exception('No cached data available. Please connect to the internet.');
  }

  void clearCache() {
    _cachedProducts = null;
    _lastFetchTime = null;
  }

  List<ProductModel> searchProducts(List<ProductModel> products, String query) {
    if (query.isEmpty) return products;
    
    final lowercaseQuery = query.toLowerCase();
    return products.where((product) =>
      product.name.toLowerCase().contains(lowercaseQuery) ||
      product.sku.toLowerCase().contains(lowercaseQuery) ||
      product.category.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  Future<PaginatedResponse<ProductModel>> getProductsPaginated(
    PaginationParams params,
  ) async {
    final isOnline = await _offlineDb.isOnline();
    
    if (!isOnline) {
      // Offline mode - return cached products with manual pagination
      final cachedProducts = await _offlineDb.getCachedProducts();
      if (cachedProducts.isEmpty) {
        return PaginatedResponse(
          success: false,
          message: 'No cached data available',
          data: [],
        );
      }
      
      final page = params.page ?? 1;
      final limit = params.limit ?? 20;
      final start = (page - 1) * limit;
      final end = start + limit;
      final paginatedProducts = cachedProducts.sublist(
        start.clamp(0, cachedProducts.length),
        end.clamp(0, cachedProducts.length),
      );
      
      return PaginatedResponse(
        success: true,
        message: 'Offline data',
        data: paginatedProducts,
        pagination: PaginationInfo(
          page: page,
          limit: limit,
          total: cachedProducts.length,
          totalPages: (cachedProducts.length / limit).ceil(),
        ),
      );
    }
    
    try {
      final response = await GetAllProductsApi.getAllProducts(params: params);
      final List<dynamic> productsData = response['data'] ?? [];
      final products = productsData.map((json) => ProductModel.fromJson(json)).toList();
      
      // Cache all products when fetching first page
      if (params.page == 1) {
        await _offlineDb.cacheProducts(products);
      }
      
      PaginationInfo? pagination;
      if (response['pagination'] != null) {
        pagination = PaginationInfo.fromJson(response['pagination']);
      }
      
      return PaginatedResponse(
        success: true,
        message: response['message'] ?? '',
        data: products,
        pagination: pagination,
      );
    } catch (e) {
      // Fallback to cached data
      final cachedProducts = await _offlineDb.getCachedProducts();
      if (cachedProducts.isNotEmpty) {
        return PaginatedResponse(
          success: true,
          message: 'Using cached data',
          data: cachedProducts,
        );
      }
      return PaginatedResponse(
        success: false,
        message: e.toString(),
        data: [],
      );
    }
  }

  Future<void> createProductOffline(Map<String, dynamic> productData) async {
    final isOnline = await _offlineDb.isOnline();
    
    if (!isOnline) {
      await _offlineDb.addPendingAction(PendingAction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: PendingActionType.createProduct,
        data: productData,
        createdAt: DateTime.now(),
      ));
      debugPrint('Product creation queued for sync');
    }
  }

  Future<void> updateProductOffline(String productId, Map<String, dynamic> productData) async {
    final isOnline = await _offlineDb.isOnline();
    
    if (!isOnline) {
      productData['_id'] = productId;
      await _offlineDb.addPendingAction(PendingAction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: PendingActionType.updateProduct,
        data: productData,
        createdAt: DateTime.now(),
      ));
      debugPrint('Product update queued for sync');
    }
  }

  Future<void> deleteProductOffline(String productId) async {
    final isOnline = await _offlineDb.isOnline();
    
    if (!isOnline) {
      await _offlineDb.addPendingAction(PendingAction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: PendingActionType.deleteProduct,
        data: {'_id': productId},
        createdAt: DateTime.now(),
      ));
      debugPrint('Product deletion queued for sync');
    }
  }
}
