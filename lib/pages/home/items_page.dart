import 'package:flutter/material.dart';
import '../items/details_page.dart';
import '../items/add_item_page.dart';
import '../../services/product_service.dart';
import '../../models/pagination_models.dart';
import '../../widgets/cached_product_image.dart';

class ItemModel {
  final String id;
  final String name;
  final String sku;
  final String cost;
  final String price;
  final int stock;
  final String image;
  final String category;
  final String ram;
  final String date;
  final String gpu;
  final String color;
  final String processor;

  ItemModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.cost,
    required this.price,
    required this.stock,
    required this.image,
    required this.category,
    required this.ram,
    required this.date,
    required this.gpu,
    required this.color,
    required this.processor,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['_id'] ?? '',
      name: json['productName'] ?? '',
      sku: json['SKU'] ?? '',
      cost: '${json['cost']} USD',
      price: '${json['price']} USD',
      stock: json['quantity'] ?? 0,
      image: json['image'] ?? '',
      category: json['category'] ?? '',
      ram: json['RAM'] ?? '',
      date: json['date'] ?? '',
      gpu: json['GPU'] ?? '',
      color: json['color'] ?? '',
      processor: json['processor'] ?? '',
    );
  }

  ProductModel toProductModel() {
    return ProductModel(
      id: id,
      name: name,
      sku: sku,
      cost: cost.replaceAll(' USD', ''),
      price: price.replaceAll(' USD', ''),
      quantity: stock,
      image: image,
      category: category,
      ram: ram,
      date: date,
      gpu: gpu,
      color: color,
      processor: processor,
    );
  }
}

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final List<ItemModel> _items = [];
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  int _currentPage = 1;
  int _total = 0;
  static const int _pageSize = 20;
  
  // Advanced search filters
  String _filterSku = '';
  String _filterName = '';
  String _filterCategory = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadProducts({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (refresh) {
        _items.clear();
        _currentPage = 1;
        _hasMore = true;
      }
    });

    try {
      final searchTerm = _searchQuery.isNotEmpty ? _searchQuery : 
          (_filterName.isNotEmpty ? _filterName : 
          (_filterSku.isNotEmpty ? _filterSku : _filterCategory));
      
      final response = await ProductService.instance.getProductsPaginated(
        PaginationParams(
          page: 1,
          limit: _pageSize,
          search: searchTerm.isNotEmpty ? searchTerm : null,
        ),
      );
      
      if (!mounted) return;
      
      setState(() {
        _items.clear();
        _items.addAll(response.data.map(_productToItem));
        _currentPage = 1;
        _hasMore = response.pagination?.hasNextPage ?? false;
        _total = response.pagination?.total ?? response.data.length;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreProducts() async {
    if (_isLoadingMore || _isLoading || !_hasMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final searchTerm = _searchQuery.isNotEmpty ? _searchQuery : 
          (_filterName.isNotEmpty ? _filterName : 
          (_filterSku.isNotEmpty ? _filterSku : _filterCategory));
      
      final response = await ProductService.instance.getProductsPaginated(
        PaginationParams(
          page: _currentPage + 1,
          limit: _pageSize,
          search: searchTerm.isNotEmpty ? searchTerm : null,
        ),
      );
      
      if (!mounted) return;
      
      setState(() {
        _items.addAll(response.data.map(_productToItem));
        _currentPage++;
        _hasMore = response.pagination?.hasNextPage ?? false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMore = false);
    }
  }

  ItemModel _productToItem(ProductModel product) {
    return ItemModel(
      id: product.id,
      name: product.name,
      sku: product.sku,
      cost: '${product.cost} USD',
      price: '${product.price} USD',
      stock: product.quantity,
      image: product.image,
      category: product.category,
      ram: product.ram,
      date: product.date,
      gpu: product.gpu,
      color: product.color,
      processor: product.processor,
    );
  }

  List<ItemModel> get filteredItems {
    if (_filterSku.isEmpty && _filterName.isEmpty && _filterCategory.isEmpty) {
      return _items;
    }
    
    return _items.where((it) {
      final bool matchesSku = _filterSku.isEmpty || 
          it.sku.toLowerCase().contains(_filterSku.toLowerCase());
      final bool matchesName = _filterName.isEmpty || 
          it.name.toLowerCase().contains(_filterName.toLowerCase());
      final bool matchesCat = _filterCategory.isEmpty || 
          it.category.toLowerCase().contains(_filterCategory.toLowerCase());
      return matchesSku && matchesName && matchesCat;
    }).toList();
  }

  void _openAdvancedSearch() async {
    final result = await showDialog<_ItemsFilterResult>(
      context: context,
      builder: (context) {
        final skuController = TextEditingController(text: _filterSku);
        final nameController = TextEditingController(text: _filterName);
        final categoryController = TextEditingController(text: _filterCategory);
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Advanced Search', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: skuController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Code (SKU)',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Type (Category)',
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, _ItemsFilterResult(
                  sku: skuController.text,
                  name: nameController.text,
                  category: categoryController.text,
                ));
              },
              child: const Text('Apply', style: TextStyle(color: Color(0xFF3B82F6))),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        _filterSku = result.sku;
        _filterName = result.name;
        _filterCategory = result.category;
      });
      _loadProducts(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Inventory Items',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _openAdvancedSearch,
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () => _loadProducts(refresh: true),
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            color: const Color(0xFF1E293B),
            onSelected: (value) async {
              if (value == 'add') {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddItemPage(),
                  ),
                );
                
                // If a product was successfully added, refresh the list
                if (result == true) {
                  _loadProducts(refresh: true);
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'add',
                child: Text(
                  'Add New Item',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'export',
                child: Text(
                  'Export to CSV',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'filter',
                child: Text(
                  'Filter Items',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text(
                  'Item Settings',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddItemPage(),
            ),
          );
          
          // If a product was successfully added, refresh the list
          if (result == true) {
            _loadProducts(refresh: true);
          }
        },
        backgroundColor: const Color(0xFF3B82F6),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: const Text(
          'Add Item',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final items = filteredItems;
    
    if (_isLoading && items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3B82F6),
        ),
      );
    }

    if (_errorMessage != null && items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Color(0xFFEF4444),
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error loading products',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _loadProducts(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF64748B),
              size: 48,
            ),
            SizedBox(height: 16),
            Text(
              'No products found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Adjust filters or add products to get started',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadProducts(refresh: true),
      color: const Color(0xFF3B82F6),
      backgroundColor: const Color(0xFF1E293B),
      child: Column(
        children: [
          // Total count header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${items.length} of $_total items',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
                if (_hasMore)
                  const Text(
                    'Scroll for more',
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: items.length + (_isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                
                final item = items[index];
                return GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailsPage(product: item.toProductModel()),
                      ),
                    );
                    
                    if (result == true) {
                      _loadProducts(refresh: true);
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF334155),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        CachedProductImage(
                          imageUrl: item.image.startsWith('http') ? item.image : null,
                          width: 50,
                          height: 50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'SKU: ${item.sku}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Price: ${item.price}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _getStockColor(item.stock),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.stock.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getStockColor(int stock) {
    if (stock >= 70) {
      return const Color(0xFF3B82F6); // Blue for high stock
    } else if (stock >= 40) {
      return const Color(0xFF50C878); // Green for medium stock
    } else if (stock >= 20) {
      return const Color(0xFFFF8C00); // Orange for low stock
    } else {
      return const Color(0xFFFF6B6B); // Red for very low stock
    }
  }
}

class _ItemsFilterResult {
  final String sku;
  final String name;
  final String category;

  _ItemsFilterResult({
    required this.sku,
    required this.name,
    required this.category,
  });
}
