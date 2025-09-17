import 'package:flutter/material.dart';
import '../items/details_page.dart';

class ItemModel {
  final String name;
  final String sku;
  final String cost;
  final String price;
  final int stock;
  final String image;

  ItemModel({
    required this.name,
    required this.sku,
    required this.cost,
    required this.price,
    required this.stock,
    required this.image,
  });
}

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  final List<ItemModel> items = [
    ItemModel(
      name: 'Microsoft Surface 4',
      sku: 'UEPYMGDO',
      cost: '1000 USD',
      price: '1400 USD',
      stock: 80,
      image: '📱',
    ),
    ItemModel(
      name: 'Acer Nitro 5',
      sku: 'OMCZHYVX',
      cost: '1200 USD',
      price: '1500 USD',
      stock: 75,
      image: '💻',
    ),
    ItemModel(
      name: 'Hp monoblock 12',
      sku: 'IQHPVMSD',
      cost: '650 USD',
      price: '800 USD',
      stock: 15,
      image: '🖥️',
    ),
    ItemModel(
      name: 'Apple MacBook Pro 14',
      sku: 'SMXAPGAID',
      cost: '1800 USD',
      price: '2500 USD',
      stock: 45,
      image: '💻',
    ),
    ItemModel(
      name: 'Lenovo ThinkPad',
      sku: 'NNEUUUKXCL',
      cost: '950 USD',
      price: '1200 USD',
      stock: 50,
      image: '💻',
    ),
  ];

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
            onPressed: () {},
            icon: const Icon(
              Icons.sort,
              color: Colors.white,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
            color: const Color(0xFF1E293B),
            onSelected: (value) {
              // Handle menu selection
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
      body: ListView.builder(
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
                  child: Center(
                    child: Text(
                      item.image,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add new item
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
