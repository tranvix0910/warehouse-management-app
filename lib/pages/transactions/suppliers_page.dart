import 'package:flutter/material.dart';
import 'add_supplier_page.dart';

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
  List<Supplier> suppliers = [
    Supplier(
      id: '1',
      name: 'ASUS Rog',
      phone: '1234567891',
      isFavorite: true,
    ),
    Supplier(
      id: '2',
      name: 'Acer Corporation',
      phone: '1234567893',
      isFavorite: true,
    ),
    Supplier(
      id: '3',
      name: 'Apple Corporation',
      phone: '1234567892',
      isFavorite: false,
    ),
    Supplier(
      id: '4',
      name: 'HP corporation',
      phone: '1234567890',
      isFavorite: false,
    ),
  ];

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
      body: ListView.builder(
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

  void _toggleFavorite(int index) {
    setState(() {
      suppliers[index] = suppliers[index].copyWith(
        isFavorite: !suppliers[index].isFavorite,
      );
    });
  }

  void _addNewSupplier() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSupplierPage(),
      ),
    ).then((newSupplierData) {
      if (newSupplierData != null) {
        setState(() {
          suppliers.add(
            Supplier(
              id: newSupplierData['id'],
              name: newSupplierData['name'],
              phone: newSupplierData['phone'],
              isFavorite: newSupplierData['isFavorite'] ?? false,
            ),
          );
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Supplier added successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      }
    });
  }
}
