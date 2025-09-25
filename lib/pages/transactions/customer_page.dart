import 'package:flutter/material.dart';
import 'add_customer_page.dart';

class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final bool isFavorite;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.isFavorite = false,
  });

  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    bool? isFavorite,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class CustomersPage extends StatefulWidget {
  const CustomersPage({super.key});

  @override
  State<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends State<CustomersPage> {
  List<CustomerModel> customers = [
    CustomerModel(id: '1', name: 'Michael Zhang', phone: '+61255541234', isFavorite: true),
    CustomerModel(id: '2', name: 'Sarah Williams', phone: '+442055567890', isFavorite: true),
    CustomerModel(id: '3', name: 'John Carter', phone: '+12125553456', isFavorite: false),
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
          'Customers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _addNewCustomer,
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
        itemCount: customers.length,
        itemBuilder: (context, index) {
          final customer = customers[index];
          return _buildCustomerItem(customer, index);
        },
      ),
    );
  }

  Widget _buildCustomerItem(CustomerModel customer, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectCustomer(customer),
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
              // Customer Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.phone,
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
                    customer.isFavorite ? Icons.star : Icons.star_border,
                    color: customer.isFavorite 
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

  void _selectCustomer(CustomerModel customer) {
    Navigator.pop(context, {
      'id': customer.id,
      'name': customer.name,
      'phone': customer.phone,
    });
  }

  void _toggleFavorite(int index) {
    setState(() {
      customers[index] = customers[index].copyWith(
        isFavorite: !customers[index].isFavorite,
      );
    });
  }

  void _addNewCustomer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddCustomerPage(),
      ),
    ).then((newCustomerData) {
      if (newCustomerData != null) {
        setState(() {
          customers.add(
            CustomerModel(
              id: newCustomerData['id'],
              name: newCustomerData['name'],
              phone: newCustomerData['phone'],
              isFavorite: newCustomerData['isFavorite'] ?? false,
            ),
          );
        });
      }
    });
  }
}
