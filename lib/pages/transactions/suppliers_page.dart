import 'package:flutter/material.dart';
import 'add_supplier_page.dart';
import '../../apis/suppliers_api.dart';
import '../../apis/add_fav_supplier.dart';
import '../../utils/snack_bar.dart';

class Supplier {
  final String id;
  final String name;
  final String phone;
  final bool isFavorite;

  Supplier({
    required this.id,
    required this.name,
    required this.phone,
    this.isFavorite = false,
  });

  Supplier copyWith({
    String? id,
    String? name,
    String? phone,
    bool? isFavorite,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  List<Supplier> suppliers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
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
          'Suppliers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _addNewSupplier,
            child: const Text(
              'Add new',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (errorMessage != null)
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadSuppliers,
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: suppliers.length,
                  itemBuilder: (context, index) {
                    final supplier = suppliers[index];
                    return _buildSupplierItem(supplier, index);
                  },
                ),
    );
  }

  Widget _buildSupplierItem(Supplier supplier, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectSupplier(supplier),
        borderRadius: BorderRadius.circular(12),
        child: Container(
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
              // Supplier Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      supplier.phone,
                      style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Favorite Icon
              GestureDetector(
                onTap: () => _toggleFavorite(index),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    supplier.isFavorite ? Icons.star : Icons.star_border,
                    color: supplier.isFavorite 
                        ? Colors.amber 
                        : Colors.grey[600],
                    size: 24,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[600],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectSupplier(Supplier supplier) {
    Navigator.pop(context, {
      'id': supplier.id,
      'name': supplier.name,
      'phone': supplier.phone,
    });
  }

  void _toggleFavorite(int index) async {
    final supplier = suppliers[index];
    final newFavoriteState = !supplier.isFavorite;
    
    // Optimistically update UI
    setState(() {
      suppliers[index] = supplier.copyWith(
        isFavorite: newFavoriteState,
      );
    });

    try {
      // Call API to update favorite status
      await AddFavoriteSupplierApi.markAsFavorite(
        supplierId: supplier.id,
      );
      
      // Show success message
      if (mounted) {
        showSuccessSnackTop(
          context, 
          newFavoriteState 
            ? 'Supplier added to favorites!' 
            : 'Supplier removed from favorites!'
        );
      }
    } catch (e) {
      // Revert UI state on error
      setState(() {
        suppliers[index] = supplier.copyWith(
          isFavorite: !newFavoriteState,
        );
      });
      
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      }
    }
  }

  void _addNewSupplier() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSupplierPage(),
      ),
    ).then((newSupplierData) async {
      if (newSupplierData != null) {
        await _loadSuppliers();
        final bool created = (newSupplierData['created'] == true);
        if (created && mounted) {
          showSuccessSnackTop(context, 'Supplier added successfully!');
        }
      }
    });
  }

  Future<void> _loadSuppliers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await GetAllSuppliersApi.getAllSuppliers();
      final List<dynamic> data = (response['data'] as List<dynamic>);

      final List<Supplier> fetched = data.map((item) {
        final Map<String, dynamic> map = item as Map<String, dynamic>;
        return Supplier(
          id: map['_id']?.toString() ?? '',
          name: map['name']?.toString() ?? '',
          phone: map['phone']?.toString() ?? '',
          isFavorite: (map['isFavorite'] as bool?) ?? false,
        );
      }).toList();

      setState(() {
        suppliers = fetched;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      );
    }
  }
}
