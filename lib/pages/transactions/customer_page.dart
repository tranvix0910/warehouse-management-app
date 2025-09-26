import 'package:flutter/material.dart';
import 'add_customer_page.dart';
import '../../apis/customer_api.dart';
import '../../apis/add_fav_customer.dart';
import '../../utils/snack_bar.dart';

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
  List<CustomerModel> customers = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
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
                        onPressed: _loadCustomers,
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                )
              : ListView.builder(
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

  void _toggleFavorite(int index) async {
    final customer = customers[index];
    final newFavoriteState = !customer.isFavorite;
    
    // Optimistically update UI
    setState(() {
      customers[index] = customer.copyWith(
        isFavorite: newFavoriteState,
      );
    });

    try {
      // Call API to update favorite status
      await AddFavoriteCustomerApi.markAsFavorite(
        customerId: customer.id,
      );
      
      // Show success message
      if (mounted) {
        showSuccessSnackTop(
          context, 
          newFavoriteState 
            ? 'Customer added to favorites!' 
            : 'Customer removed from favorites!'
        );
      }
    } catch (e) {
      // Revert UI state on error
      setState(() {
        customers[index] = customer.copyWith(
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

  Future<void> _loadCustomers() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await GetAllCustomersApi.getAllCustomers();
      final List<dynamic> data = response['data'] as List<dynamic>;

      final List<CustomerModel> fetched = data.map((item) {
        final Map<String, dynamic> map = item as Map<String, dynamic>;
        return CustomerModel(
          id: map['_id']?.toString() ?? '',
          name: map['name']?.toString() ?? '',
          phone: map['phone']?.toString() ?? '',
          isFavorite: (map['isFavorite'] as bool?) ?? false,
        );
      }).toList();

      setState(() {
        customers = fetched;
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
