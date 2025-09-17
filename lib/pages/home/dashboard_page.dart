import 'package:flutter/material.dart';
import '../../core/firebase_db_service.dart.dart';
import '../../utils/token_storage.dart';
import '../../apis/get_all_product_api.dart';
import '../items/add_item_page.dart';
import '../items/details_page.dart';

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

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
        // Chỉ lấy 5 sản phẩm đầu tiên
        items = productsData
            .take(5)
            .map((json) => ItemModel.fromJson(json))
            .toList();
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Header
              _buildUserHeader(),
              const SizedBox(height: 30),

              // Stats Cards
              _buildStatsCards(),
              const SizedBox(height: 30),

              // Environment Panel (Temperature & Humidity)
              EnvironmentPanel(service: FirebaseEnvironmentService()),
              const SizedBox(height: 20),

              // Action Buttons
              _buildActionButtons(),
              const SizedBox(height: 30),

              // Items Section
              _buildItemsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: TokenStorage.getUser(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final String displayName =
            (user != null && (user['username'] ?? '').toString().isNotEmpty)
            ? user['username'].toString()
            : 'Guest';
        final String? avatarURL = user?['avatar'];
        return Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFF3B82F6),
              child: ClipOval(
                child: avatarURL != null && avatarURL.isNotEmpty
                    ? Image.network(
                        avatarURL,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          );
                        },
                      )
                    : Image.asset(
                        'https://res.cloudinary.com/djmeybzjk/image/upload/v1756449865/pngfind.com-placeholder-png-6104451_awuxxc.png',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Today',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Aug 28, 2025',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatItem('276', 'Total')),
              Expanded(child: _buildStatItem('374', 'Stock In')),
              Expanded(child: _buildStatItem('98', 'Stock Out')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.arrow_downward,
            label: 'Stock In',
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            icon: Icons.arrow_upward,
            label: 'Stock Out',
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.open_in_full, color: Colors.white, size: 24),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Items',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () async {
                // Chuyển trực tiếp đến trang Add Item
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddItemPage(),
                  ),
                );
                
                // Nếu có sản phẩm được thêm, refresh danh sách
                if (result == true) {
                  _loadProducts();
                }
              },
              child: const Text(
                '+ Add item',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildItemsList(),
      ],
    );
  }

  Widget _buildItemsList() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(
            color: Color(0xFF3B82F6),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
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
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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
                fontSize: 16,
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

    return Column(
      children: items
          .map((item) => _buildItemCard(item))
          .toList(),
    );
  }

  Widget _buildItemCard(ItemModel item) {
    return GestureDetector(
      onTap: () {
        // Chuyển đến trang chi tiết sản phẩm
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
                  Row(
                    children: [
                      Text(
                        'Cost: ${item.cost}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Price: ${item.price}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
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
