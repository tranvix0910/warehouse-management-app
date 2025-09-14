import 'package:flutter/material.dart';
import '../../apis/add_product_api.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({Key? key}) : super(key: key);

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _rfidUUID;
  String? _selectedCategory;
  String? _selectedRAM;
  String? _selectedGPU;
  String? _selectedColor;
  String? _selectedProcessor;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _costController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Add Item',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveItem,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Color(0xFF3B82F6),
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            _buildImageSection(),
            const SizedBox(height: 24),

            // Item Name
            _buildTextInputField(
              label: 'Item Name',
              controller: _nameController,
              hint: 'Enter item name',
            ),
            const SizedBox(height: 16),

            // SKU (RFID UUID)
            _buildSelectableField(
              label: 'SKU',
              value: _rfidUUID,
              onTap: () => _showSKUInputMethodDialog(),
            ),
            const SizedBox(height: 16),

            // Category
            _buildSelectableField(
              label: 'Category',
              value: _selectedCategory,
              onTap: () => _showCategoryDialog(),
            ),
            const SizedBox(height: 24),

            // Price and Quantity Section
            _buildSectionTitle('Price and quantity'),
            const SizedBox(height: 16),

            _buildTextInputField(
              label: 'Quantity',
              controller: _quantityController,
              hint: 'Enter the quantity',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            _buildTextInputField(
              label: 'Cost',
              controller: _costController,
              hint: 'Enter the cost',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            _buildTextInputField(
              label: 'Price',
              controller: _priceController,
              hint: 'Enter the price',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Attributes Section
            _buildAttributesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF475569),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _pickImage,
            child: const Text(
              'Add image',
              style: TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
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
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF334155),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableField({
    required String label,
    String? value,
    required VoidCallback onTap,
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
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF334155),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value ?? (label == 'SKU' ? 'Scan RFID card to get UUID' : 'Select $label'),
                  style: TextStyle(
                    color: value != null ? Colors.white : const Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAttributesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Attributes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF64748B),
                  size: 20,
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Change',
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // RAM
        _buildAttributeField(
          label: 'RAM',
          value: _selectedRAM,
          onTap: () => _showRAMDialog(),
        ),
        const SizedBox(height: 16),

        // Date
        _buildAttributeField(
          label: 'Date',
          value: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
          onTap: () => _showDatePicker(),
        ),
        const SizedBox(height: 16),

        // GPU
        _buildAttributeField(
          label: 'GPU',
          value: _selectedGPU,
          onTap: () => _showGPUDialog(),
        ),
        const SizedBox(height: 16),

        // Color
        _buildAttributeField(
          label: 'Color',
          value: _selectedColor,
          onTap: () => _showColorDialog(),
        ),
        const SizedBox(height: 16),

        // Processor
        _buildAttributeField(
          label: 'Processor',
          value: _selectedProcessor,
          onTap: () => _showProcessorDialog(),
        ),
      ],
    );
  }

  Widget _buildAttributeField({
    required String label,
    String? value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF334155),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Text(
                  value ?? 'Add value',
                  style: TextStyle(
                    color: value != null ? Colors.white : const Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF64748B),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() {
    // Implement image picker functionality
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text('Camera', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Implement camera functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: const Text('Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Implement gallery functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSKUInputMethodDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SKU input method',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Scan with RFID Card option
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.credit_card,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              title: const Text(
                'Scan with RFID Card',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _scanWithRFID();
              },
            ),
            
            const SizedBox(height: 16),
            
            // Manual RFID input option
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.keyboard,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              title: const Text(
                'Manual RFID Input',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Enter RFID card data manually',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _manualRFIDInput();
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog() {
    _showSelectionDialog(
      title: 'Select Category',
      options: ['Ultrabook', 'Gaming', '2-in-1', 'Business', 'Creator'],
      currentValue: _selectedCategory,
      onSelected: (value) => setState(() => _selectedCategory = value),
    );
  }

  void _showRAMDialog() {
    _showSelectionDialog(
      title: 'Select RAM',
      options: ['4GB', '8GB', '16GB', '32GB', '64GB'],
      currentValue: _selectedRAM,
      onSelected: (value) => setState(() => _selectedRAM = value),
    );
  }

  void _showGPUDialog() {
    _showSelectionDialog(
      title: 'Select GPU',
      options: ['Intel Iris Xe', 'Intel UHD Graphics', 'NVIDIA GTX 1650', 'NVIDIA GTX 1650 Ti', 'NVIDIA RTX 3060', 'NVIDIA RTX 3070', 'NVIDIA RTX 3070 Ti', 'Apple M2 GPU'],
      currentValue: _selectedGPU,
      onSelected: (value) => setState(() => _selectedGPU = value),
    );
  }

  void _showColorDialog() {
    _showSelectionDialog(
      title: 'Select Color',
      options: ['Black', 'Silver', 'White', 'Space Gray', 'Blue', 'Red', 'Platinum', 'Emerald Green', 'Dark Gray'],
      currentValue: _selectedColor,
      onSelected: (value) => setState(() => _selectedColor = value),
    );
  }

  void _showProcessorDialog() {
    _showSelectionDialog(
      title: 'Select Processor',
      options: ['Intel Core i5-1135G7', 'Intel Core i5-1235U', 'Intel Core i5-10210U', 'Intel Core i5-11400H', 'Intel Core i7-1165G7', 'Intel Core i7-1195G7', 'Intel Core i7-1255U', 'Intel Core i7-1260P', 'Intel Core i7-10750H', 'Intel Core i7-11800H', 'Intel Core i7-12700H', 'AMD Ryzen 5 5800H', 'AMD Ryzen 7 5800H', 'Apple M2'],
      currentValue: _selectedProcessor,
      onSelected: (value) => setState(() => _selectedProcessor = value),
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showSelectionDialog({
    required String title,
    required List<String> options,
    String? currentValue,
    required Function(String) onSelected,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((option) => ListTile(
            title: Text(
              option,
              style: const TextStyle(color: Colors.white),
            ),
            leading: Radio<String>(
              value: option,
              groupValue: currentValue,
              onChanged: (value) {
                if (value != null) {
                  onSelected(value);
                  Navigator.pop(context);
                }
              },
              activeColor: const Color(0xFF3B82F6),
            ),
          )).toList(),
        ),
      ),
    );
  }

  void _scanWithRFID() {
    // Implement RFID scanning functionality
    // For now, we'll simulate RFID scanning
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF3B82F6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Scanning RFID Card...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Place RFID card near the reader',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );

    // Simulate scanning delay
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading dialog
      
      // Generate a realistic RFID UUID format
      String generateRFIDUUID() {
        final random = DateTime.now().millisecondsSinceEpoch;
        final part1 = (random % 0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
        final part2 = ((random ~/ 1000) % 0xFFFF).toRadixString(16).padLeft(4, '0');
        final part3 = ((random ~/ 10000) % 0xFFFF).toRadixString(16).padLeft(4, '0');
        final part4 = ((random ~/ 100000) % 0xFFFF).toRadixString(16).padLeft(4, '0');
        final part5 = ((random ~/ 1000000) % 0xFFFFFFFFFFFF).toRadixString(16).padLeft(12, '0');
        
        return '${part1}-${part2}-${part3}-${part4}-${part5}'.toUpperCase();
      }
      
      // Set the scanned RFID UUID
      setState(() {
        _rfidUUID = generateRFIDUUID();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('RFID UUID: $_rfidUUID'),
          backgroundColor: const Color(0xFF50C878),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  void _manualRFIDInput() {
    TextEditingController rfidController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Manual RFID Input',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter RFID card data:',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rfidController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g., A1B2C3D4-E5F6-7890-1234-567890ABCDEF',
                hintStyle: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
                filled: true,
                fillColor: const Color(0xFF334155),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 8),
            const Text(
              'Format: XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              String rfidInput = rfidController.text.trim().toUpperCase();
              
              if (rfidInput.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter RFID data'),
                    backgroundColor: Color(0xFFEF4444),
                  ),
                );
                return;
              }
              
              // Validate RFID format (basic validation)
              if (rfidInput.length < 8) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('RFID data is too short'),
                    backgroundColor: Color(0xFFEF4444),
                  ),
                );
                return;
              }
              
              Navigator.pop(context);
              
              // Set the manually entered RFID UUID
              setState(() {
                _rfidUUID = rfidInput;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('RFID UUID: $_rfidUUID'),
                  backgroundColor: const Color(0xFF50C878),
                  duration: const Duration(seconds: 3),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _saveItem() async {
    // Validate required fields
    if (_nameController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter item name');
      return;
    }

    if (_rfidUUID == null || _rfidUUID!.isEmpty) {
      _showErrorSnackBar('Please scan or enter SKU');
      return;
    }

    if (_selectedCategory == null) {
      _showErrorSnackBar('Please select a category');
      return;
    }

    if (_quantityController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter quantity');
      return;
    }

    if (_costController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter cost');
      return;
    }

    if (_priceController.text.trim().isEmpty) {
      _showErrorSnackBar('Please enter price');
      return;
    }

    if (_selectedRAM == null) {
      _showErrorSnackBar('Please select RAM');
      return;
    }

    if (_selectedGPU == null) {
      _showErrorSnackBar('Please select GPU');
      return;
    }

    if (_selectedColor == null) {
      _showErrorSnackBar('Please select color');
      return;
    }

    if (_selectedProcessor == null) {
      _showErrorSnackBar('Please select processor');
      return;
    }

    // Validate numeric fields
    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      _showErrorSnackBar('Please enter a valid quantity');
      return;
    }

    final cost = double.tryParse(_costController.text.trim());
    if (cost == null || cost <= 0) {
      _showErrorSnackBar('Please enter a valid cost');
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      _showErrorSnackBar('Please enter a valid price');
      return;
    }

    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // Format date as YYYY-MM-DD
      final formattedDate = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

      // Call the API
      await AddProductApi.addProduct(
        productName: _nameController.text.trim(),
        sku: _rfidUUID!,
        category: _selectedCategory!,
        cost: _costController.text.trim(),
        price: _priceController.text.trim(),
        quantity: _quantityController.text.trim(),
        ram: _selectedRAM!,
        date: formattedDate,
        gpu: _selectedGPU!,
        color: _selectedColor!,
        processor: _selectedProcessor!,
        barcode: _rfidUUID, // Using RFID UUID as barcode for now
        image: null, // TODO: Implement image upload later
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product created successfully!'),
            backgroundColor: Color(0xFF50C878),
            duration: Duration(seconds: 2),
          ),
        );

        // Navigate back to items page
        Navigator.pop(context, true); // Return true to indicate success
      }

    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
