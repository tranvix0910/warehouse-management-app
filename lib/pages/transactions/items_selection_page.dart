import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/product_service.dart';

class SelectedItem {
  final ProductModel product;
  int quantity;

  SelectedItem({
    required this.product,
    this.quantity = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'name': product.name,
      'sku': product.sku,
      'quantity': quantity,
      'image': product.image,
      'price': product.price,
      'cost': product.cost,
    };
  }
}

class ItemsSelectionPage extends StatefulWidget {
  final List<Map<String, dynamic>>? preSelectedItems;
  
  const ItemsSelectionPage({
    super.key,
    this.preSelectedItems,
  });

  @override
  State<ItemsSelectionPage> createState() => _ItemsSelectionPageState();
}

class _ItemsSelectionPageState extends State<ItemsSelectionPage> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];
  List<SelectedItem> selectedItems = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeSelectedItems();
    _loadProducts();
  }

  void _initializeSelectedItems() {
    if (widget.preSelectedItems != null) {
      // Convert pre-selected items to SelectedItem objects
      for (var item in widget.preSelectedItems!) {
        final product = ProductModel(
          id: item['productId'] ?? '',
          name: item['name'] ?? '',
          sku: item['sku'] ?? '',
          cost: item['cost'] ?? '0',
          price: item['price'] ?? '0',
          quantity: 0,
          image: item['image'] ?? '',
          category: '',
          ram: '',
          date: '',
          gpu: '',
          color: '',
          processor: '',
        );
        
        selectedItems.add(SelectedItem(
          product: product,
          quantity: item['quantity'] ?? 1,
        ));
      }
    }
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final products = await ProductService.instance.getProducts();
      
      setState(() {
        allProducts = products;
        filteredProducts = products;
        isLoading = false;
      });
      
      // Update selected items with full product data after loading
      _updateSelectedItemsWithFullData();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _updateSelectedItemsWithFullData() {
    if (widget.preSelectedItems != null && allProducts.isNotEmpty) {
      setState(() {
        selectedItems.clear();
        for (var item in widget.preSelectedItems!) {
          final product = allProducts.firstWhere(
            (p) => p.id == item['productId'],
            orElse: () => ProductModel(
              id: item['productId'] ?? '',
              name: item['name'] ?? '',
              sku: item['sku'] ?? '',
              cost: item['cost'] ?? '0',
              price: item['price'] ?? '0',
              quantity: 0,
              image: item['image'] ?? '',
              category: '',
              ram: '',
              date: '',
              gpu: '',
              color: '',
              processor: '',
            ),
          );
          
          selectedItems.add(SelectedItem(
            product: product,
            quantity: item['quantity'] ?? 1,
          ));
        }
      });
    }
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = ProductService.instance.searchProducts(allProducts, query);
    });
  }

  // Selection is handled via quantity dialog on tap

  void _updateItemQuantity(String productId, int quantity) {
    setState(() {
      final index = selectedItems.indexWhere((item) => item.product.id == productId);
      if (index >= 0) {
        if (quantity > 0) {
          selectedItems[index].quantity = quantity;
        } else {
          selectedItems.removeAt(index);
        }
      }
    });
  }

  bool _isItemSelected(String productId) {
    return selectedItems.any((item) => item.product.id == productId);
  }

  int _getSelectedQuantity(String productId) {
    final item = selectedItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => SelectedItem(product: ProductModel(
        id: '', name: '', sku: '', cost: '', price: '', quantity: 0,
        image: '', category: '', ram: '', date: '', gpu: '', color: '', processor: '',
      ), quantity: 0),
    );
    return item.quantity;
  }

  void _showQuantityDialog(ProductModel product) {
    final currentQuantity = _getSelectedQuantity(product.id);
    final TextEditingController controller = TextEditingController(
      text: currentQuantity > 0 ? currentQuantity.toString() : '',
    );
    bool isValid = currentQuantity > 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void onChanged(String value) {
              final intVal = int.tryParse(value) ?? 0;
              setState(() {
                isValid = intVal > 0 && intVal <= product.quantity;
              });
            }

            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF334155), width: 1),
              ),
              title: const Text(
                'Enter the quantity',
                style: TextStyle(color: Colors.white),
              ),
              content: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: onChanged,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Quantity',
                  hintStyle: TextStyle(color: Colors.grey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF334155)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF3B82F6)),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: isValid
                      ? () {
                          final qty = int.tryParse(controller.text) ?? 0;
                          if (!_isItemSelected(product.id) && qty > 0) {
                            selectedItems.add(SelectedItem(product: product, quantity: qty));
                          } else {
                            _updateItemQuantity(product.id, qty);
                          }
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('Apply', style: TextStyle(color: Color(0xFF3B82F6))),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Items',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _doneSelection,
            child: const Text(
              'Done',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar (only show when not loading)
          if (!isLoading)
            Container(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: _filterProducts,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search for items',
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF3B82F6)),
                  ),
                ),
              ),
            ),
          
          // Products List
          Expanded(
            child: _buildBody(),
          ),
          
          // Selected Items Counter
          if (selectedItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                border: Border(
                  top: BorderSide(color: Color(0xFF334155), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${selectedItems.length} items selected',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      selectedItems.length.toString(),
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
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Column(
        children: [
          // Show search bar even while loading
          Container(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Text(
                    'Loading products...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Loading indicator
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading products...',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load products',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.w500,
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

    if (filteredProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty 
                  ? 'No items found'
                  : 'No products available',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        final isSelected = _isItemSelected(product.id);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => _showQuantityDialog(product),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF334155),
                  width: isSelected ? 2 : 1,
                ),
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
                    child: product.image.startsWith('http')
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.image,
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
                        : const Center(
                            child: Icon(
                              Icons.laptop,
                              color: Color(0xFF64748B),
                              size: 24,
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
                          product.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SKU: ${product.sku}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Stock & Selection
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStockColor(product.quantity),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          product.quantity.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
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

  void _doneSelection() {
    final selectedItemsData = selectedItems.map((item) => item.toJson()).toList();
    Navigator.pop(context, selectedItemsData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
