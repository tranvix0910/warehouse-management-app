import '../apis/product_api.dart';

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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'cost': cost,
      'price': price,
      'quantity': quantity,
      'image': image,
      'category': category,
      'ram': ram,
      'date': date,
      'gpu': gpu,
      'color': color,
      'processor': processor,
    };
  }
}

class ProductService {
  static ProductService? _instance;
  static ProductService get instance => _instance ??= ProductService._();
  
  ProductService._();

  List<ProductModel>? _cachedProducts;
  DateTime? _lastFetchTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  Future<List<ProductModel>> getProducts({bool forceRefresh = false}) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && 
        _cachedProducts != null && 
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration) {
      return _cachedProducts!;
    }

    try {
      final response = await GetAllProductsApi.getAllProducts();
      final List<dynamic> productsData = response['data'] ?? [];
      
      _cachedProducts = productsData.map((json) => ProductModel.fromJson(json)).toList();
      _lastFetchTime = DateTime.now();
      
      return _cachedProducts!;
    } catch (e) {
      // If we have cached data, return it even if refresh failed
      if (_cachedProducts != null) {
        return _cachedProducts!;
      }
      rethrow;
    }
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
}
