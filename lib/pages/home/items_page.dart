import 'package:flutter/material.dart';
import '../items/details_page.dart';
import '../items/add_item_page.dart';
import '../../apis/get_all_product_api.dart';

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
}

class ItemsPage extends StatefulWidget {
  const ItemsPage({Key? key}) : super(key: key);

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  List<ItemModel> items = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await GetAllProductsApi.getAllProducts();
      final List<dynamic> productsData = response['data'] ?? [];
      
      setState(() {
        items = productsData.map((json) => ItemModel.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
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
            onPressed: () {},
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: _loadProducts,
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
                  _loadProducts();
                }
              }
              // Handle other menu selections
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
            _loadProducts();
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
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3B82F6),
        ),
      );
    }

    if (errorMessage != null) {
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
            Text(
              'Error loading products',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProducts,
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
              'Add some products to get started',
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
      onRefresh: _loadProducts,
      color: const Color(0xFF3B82F6),
      backgroundColor: const Color(0xFF1E293B),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemDetailsPage(
                    item: {
                      'name': item.name,
                      'sku': item.sku,
                      'cost': item.cost,
                      'price': item.price,
                      'stock': item.stock.toString(),
                    },
                  ),
                ),
              );
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Product Image
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF334155),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: item.image.startsWith('http')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              item.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.laptop,
                                    color: Color(0xFF64748B),
                                    size: 24,
                                  ),
                                );
                              },
                            ),
                          )
                        : Center(
                            child: Text(
                              item.image.isEmpty ? '💻' : item.image,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Product Info
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
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SKU: ${item.sku}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cost: ${item.cost}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                  // Stock Number
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
