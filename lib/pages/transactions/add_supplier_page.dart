import 'package:flutter/material.dart';
import '../../apis/add_suppliers_api.dart';
import '../../utils/snack_bar.dart';

class AddSupplierPage extends StatefulWidget {
  const AddSupplierPage({super.key});

  @override
  State<AddSupplierPage> createState() => _AddSupplierPageState();
}

class _AddSupplierPageState extends State<AddSupplierPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
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
          'Supplier',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name Field
                  _buildInputField(
                    label: 'Name',
                    controller: _nameController,
                    hintText: 'Enter name',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Phone Field
                  _buildInputField(
                    label: 'Phone',
                    controller: _phoneController,
                    hintText: 'Enter phone',
                    keyboardType: TextInputType.phone,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Email Field
                  _buildInputField(
                    label: 'Email',
                    controller: _emailController,
                    hintText: 'Enter email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Address Field
                  _buildInputField(
                    label: 'Address',
                    controller: _addressController,
                    hintText: 'Enter address',
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Notes Field
                  _buildInputField(
                    label: 'Notes',
                    controller: _notesController,
                    hintText: 'Enter notes (optional)',
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),
          
          // Create Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : _createSupplier,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF334155),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _createSupplier() async {
    // Validate required fields
    final String name = _nameController.text.trim();
    final String phoneText = _phoneController.text.trim();
    final String email = _emailController.text.trim();
    final String address = _addressController.text.trim();
    final String notes = _notesController.text.trim();

    if (name.isEmpty) {
      showErrorSnackTop(context, 'Please enter supplier name');
      return;
    }
    if (phoneText.isEmpty) {
      showErrorSnackTop(context, 'Please enter phone number');
      return;
    }
    int? phoneInt = int.tryParse(phoneText);
    if (phoneInt == null) {
      showErrorSnackTop(context, 'Phone must be a number');
      return;
    }

    setState(() { _submitting = true; });
    try {
      final res = await AddSupplierApi.addSupplier(
        name: name,
        email: email,
        address: address,
        notes: notes.isEmpty ? null : notes,
        phone: phoneInt,
      );

      final Map<String, dynamic> data = res['data'] as Map<String, dynamic>;

      // Return to previous page and let it display a single success notification
      Navigator.pop(context, {
        'created': true,
        'id': data['_id']?.toString() ?? '',
        'name': data['name']?.toString() ?? name,
        'phone': (data['phone']?.toString() ?? phoneText),
        'isFavorite': (data['isFavorite'] as bool?) ?? false,
      });
    } catch (e) {
      showErrorSnackTop(context, e.toString());
    } finally {
      if (mounted) {
        setState(() { _submitting = false; });
      }
    }
  }

  
}
