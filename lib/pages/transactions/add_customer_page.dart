import 'package:flutter/material.dart';
import '../../apis/add_customer_api.dart';
import '../../utils/snack_bar.dart';

class AddCustomerPage extends StatefulWidget {
  const AddCustomerPage({super.key});

  @override
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _submitting = false;

  bool get _canCreate =>
      _nameController.text.trim().isNotEmpty && _phoneController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFormChange);
    _phoneController.addListener(_onFormChange);
  }

  void _onFormChange() {
    setState(() {});
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
          'Customer',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
                  const Text(
                    'Customer Information',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _label('Name'),
                  _buildTextField('Enter name', _nameController),
                  const SizedBox(height: 12),

                  _label('Phone'),
                  _buildTextField('Enter phone', _phoneController, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),

                  _label('Email'),
                  _buildTextField('Enter your email', _emailController, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),

                  _label('Address'),
                  _buildTextField('Enter your address', _addressController),
                  const SizedBox(height: 12),

                  _label('Notes'),
                  _buildTextField('Enter notes (optional)', _notesController, maxLines: 4),
                ],
              ),
            ),
          ),

          // Bottom Create button
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _canCreate && !_submitting ? _createCustomer : null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.disabled)) {
                    return const Color(0xFF334155);
                  }
                  return const Color(0xFF3B82F6);
                }),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                padding: MaterialStateProperty.all<EdgeInsets>(
                  const EdgeInsets.symmetric(vertical: 14),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
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
    );
  }

  Future<void> _createCustomer() async {
    final String name = _nameController.text.trim();
    final String phoneText = _phoneController.text.trim();
    final String email = _emailController.text.trim();
    final String address = _addressController.text.trim();
    final String notes = _notesController.text.trim();

    if (name.isEmpty) {
      showErrorSnackTop(context, 'Please enter customer name');
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
      final res = await AddCustomerApi.addCustomer(
        name: name,
        email: email,
        address: address,
        notes: notes.isEmpty ? null : notes,
        phone: phoneInt,
      );

      final Map<String, dynamic> data = res['data'] as Map<String, dynamic>;

      // Show success notification before navigating back
      showSuccessSnackTop(context, 'Customer added successfully!');

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

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
