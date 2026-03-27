import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/product_service.dart';

class ProductState {
  final List<ProductModel> products;
  final List<ProductModel> filteredProducts;
  final bool isLoading;
  final String? errorMessage;
  final String searchQuery;
  final String? categoryFilter;
  
  const ProductState({
    this.products = const [],
    this.filteredProducts = const [],
    this.isLoading = false,
    this.errorMessage,
    this.searchQuery = '',
    this.categoryFilter,
  });

  ProductState copyWith({
    List<ProductModel>? products,
    List<ProductModel>? filteredProducts,
    bool? isLoading,
    String? errorMessage,
    String? searchQuery,
    String? categoryFilter,
  }) {
    return ProductState(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
    );
  }
}

class ProductNotifier extends StateNotifier<ProductState> {
  ProductNotifier() : super(const ProductState());

  final _productService = ProductService.instance;

  Future<void> loadProducts({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    
    try {
      final products = await _productService.getProducts(forceRefresh: forceRefresh);
      state = state.copyWith(
        products: products,
        filteredProducts: _applyFilters(products, state.searchQuery, state.categoryFilter),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void search(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredProducts: _applyFilters(state.products, query, state.categoryFilter),
    );
  }

  void filterByCategory(String? category) {
    state = state.copyWith(
      categoryFilter: category,
      filteredProducts: _applyFilters(state.products, state.searchQuery, category),
    );
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      categoryFilter: null,
      filteredProducts: state.products,
    );
  }

  List<ProductModel> _applyFilters(List<ProductModel> products, String query, String? category) {
    var filtered = products;
    
    if (query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      filtered = filtered.where((product) =>
        product.name.toLowerCase().contains(lowercaseQuery) ||
        product.sku.toLowerCase().contains(lowercaseQuery) ||
        product.category.toLowerCase().contains(lowercaseQuery)
      ).toList();
    }
    
    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((product) => 
        product.category.toLowerCase() == category.toLowerCase()
      ).toList();
    }
    
    return filtered;
  }

  void clearCache() {
    _productService.clearCache();
    state = const ProductState();
  }

  List<String> getCategories() {
    return state.products
        .map((p) => p.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
  }

  ProductModel? getProductById(String id) {
    try {
      return state.products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
