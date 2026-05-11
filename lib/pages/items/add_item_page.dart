import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../apis/add_product_api.dart';
import '../../utils/snack_bar.dart';
import '../../services/product_service.dart';
import '../../services/barcode_scanner_service.dart';

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

  final TextEditingController _ramController = TextEditingController();
  final TextEditingController _gpuController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _processorController = TextEditingController();
  
  String? _rfidUUID;
  String? _selectedZone;
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  
  // Image picker variables
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _costController.dispose();
    _priceController.dispose();
    _ramController.dispose();
    _gpuController.dispose();
    _colorController.dispose();
    _processorController.dispose();
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
            if (_selectedZone != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF10B981), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Detected at: $_selectedZone',
                      style: const TextStyle(color: Color(0xFF10B981), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
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
            child: _selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _selectedImageBytes != null
                        ? Image.memory(
                            _selectedImageBytes!,
                            width: 116,
                            height: 116,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.error,
                                size: 48,
                                color: Color(0xFFEF4444),
                              );
                            },
                          )
                        : const Icon(
                            Icons.image,
                            size: 48,
                            color: Color(0xFF64748B),
                          ),
                  )
                : const Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: Color(0xFF64748B),
                  ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _pickImage,
            child: Text(
              _selectedImage != null ? 'Change image' : 'Add image',
              style: const TextStyle(
                color: Color(0xFF3B82F6),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (_selectedImage != null) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedImage = null;
                });
              },
              child: const Text(
                'Remove image',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
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
        _buildTextInputField(
          label: 'RAM',
          controller: _ramController,
          hint: 'e.g., 16GB, 32GB',
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
        _buildTextInputField(
          label: 'GPU',
          controller: _gpuController,
          hint: 'e.g., Intel Iris Xe, NVIDIA RTX 3060',
        ),
        const SizedBox(height: 16),

        // Color
        _buildTextInputField(
          label: 'Color',
          controller: _colorController,
          hint: 'e.g., Silver, Black, Space Gray',
        ),
        const SizedBox(height: 16),

        // Processor
        _buildTextInputField(
          label: 'Processor',
          controller: _processorController,
          hint: 'e.g., Intel Core i7-1165G7, AMD Ryzen 7',
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
    if (kIsWeb) {
      // Web: Show file picker
      _pickImageWeb();
    } else {
      // Mobile: Show camera/gallery options
      _pickImageMobile();
    }
  }

  void _pickImageWeb() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _selectedImageBytes = bytes;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image selected successfully!'),
            backgroundColor: Color(0xFF50C878),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackTop(context, 'Failed to pick image: $e');
      }
    }
  }

  void _pickImageMobile() {
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
              'Select Image',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Camera option
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
                  Icons.camera_alt,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              title: const Text(
                'Camera',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Take a photo',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromSource(ImageSource.camera);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Gallery option
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
                  Icons.photo_library,
                  color: Color(0xFF10B981),
                  size: 20,
                ),
              ),
              title: const Text(
                'Gallery',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Choose from gallery',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromSource(ImageSource.gallery);
              },
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _pickImageFromSource(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImage = image;
          _selectedImageBytes = bytes;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image ${source == ImageSource.camera ? 'captured' : 'selected'} successfully!'),
            backgroundColor: const Color(0xFF50C878),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackTop(context, 'Failed to ${source == ImageSource.camera ? 'capture' : 'select'} image: $e');
      }
    }
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
            
            // Scan Barcode/QR Code option (NEW - Real scanner)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              title: const Text(
                'Scan Barcode/QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Use camera to scan barcode or QR code',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _scanBarcode();
              },
            ),
            
            const SizedBox(height: 16),
            
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
              subtitle: const Text(
                'Simulate RFID card scanning',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _scanWithRFID();
              },
            ),
            
            const SizedBox(height: 16),
            
            // Manual input option
            // Scan QR Code option
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              title: const Text(
                'Scan QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Read QR code from Firebase',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _scanWithQRCode();
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
                'Manual Input',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: const Text(
                'Enter SKU manually',
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

  void _scanBarcode() async {
    if (kIsWeb) {
      showErrorSnackTop(context, 'Barcode scanning is not supported on web');
      return;
    }
    
    final result = await BarcodeScannerService.scanBarcode(context);
    
    if (result != null && mounted) {
      setState(() {
        _rfidUUID = result;
        _selectedZone = null;
      });
      
      showSuccessSnackTop(context, 'Barcode scanned: $result');
    }
  }

  void _showCategoryDialog() {
    _showSelectionDialog(
      title: 'Select Category',
      options: ['Ultrabook', 'Gaming', '2-in-1', 'Business', 'Creator'],
      currentValue: _selectedCategory,
      onSelected: (value) => setState(() => _selectedCategory = value),
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

  void _scanWithRFID() async {
    // Set check_rfid = true để bắt đầu scan
    try {
      final ref = FirebaseDatabase.instance.ref('sensors');
      await ref.update({'check_rfid': true});
      
      print('🔵 RFID Scan started: check_rfid = true');
    } catch (e) {
      print('❌ Error setting check_rfid: $e');
      return;
    }
    
    bool isScanning = true;
    
    // Show dialog đang scan
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
              'Waiting for RFID...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scanning RFID card from Firebase (Zone 1/2)',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );

    // Listen cho sensors data (bao gồm uid_1 và uid_2)
    final ref = FirebaseDatabase.instance.ref('sensors');
    late final subscription;
    
    subscription = ref.onValue.listen((event) async {
      if (!isScanning || !mounted) return;
      
      if (event.snapshot.exists && event.snapshot.value != null) {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        
        String? rfidUid;
        String? detectedZone;

        // Check uid_1 first
        if (data.containsKey('uid_1') && data['uid_1'].toString().isNotEmpty && 
            data['uid_1'].toString() != 'null' && data['uid_1'].toString() != '""') {
          rfidUid = data['uid_1'].toString();
          detectedZone = 'zone1';
        } 
        // Then check uid_2
        else if (data.containsKey('uid_2') && data['uid_2'].toString().isNotEmpty && 
            data['uid_2'].toString() != 'null' && data['uid_2'].toString() != '""') {
          rfidUid = data['uid_2'].toString();
          detectedZone = 'zone2';
        }
        
        if (rfidUid != null) {
          print('✅ RFID Data received from $detectedZone: $rfidUid');
          
          // Cancel subscription ngay
          isScanning = false;
          await subscription.cancel();
          
          // Trả về check_rfid = false và uid_1, uid_2 = ""
          try {
            await FirebaseDatabase.instance.ref('sensors').update({
              'check_rfid': false,
              'uid_1': "",
              'uid_2': "",
            });
            print('🔴 RFID Scan stopped: sensors reset');
          } catch (e) {
            print('❌ Error resetting sensors: $e');
          }
          
          // Close dialog safely
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          
          // Set SKU và Zone
          if (mounted) {
            setState(() {
              _rfidUUID = rfidUid;
              _selectedZone = detectedZone;
            });
            
            // Show success
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ RFID Scanned at $detectedZone: $_rfidUUID'),
                backgroundColor: const Color(0xFF50C878),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    });
    
    // Timeout sau 30 giây
    Future.delayed(const Duration(seconds: 30), () async {
      if (!isScanning || !mounted) return;
      
      isScanning = false;
      await subscription.cancel();
      
      // Set check_rfid = false
      try {
        await FirebaseDatabase.instance.ref('sensors').update({
          'check_rfid': false,
          'uid_1': "",
          'uid_2': "",
        });
        print('⏱️ Timeout: sensors reset');
      } catch (e) {
        print('❌ Error: $e');
      }
      
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏱️ RFID Scan timeout. Please try again.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _scanWithQRCode() async {
    // Set check_qr = true để bắt đầu scan
    try {
      final ref = FirebaseDatabase.instance.ref('sensors');
      await ref.update({'check_qr': true});
      
      print('🔵 QR Scan started: check_qr = true');
    } catch (e) {
      print('❌ Error setting check_qr: $e');
      return;
    }
    
    bool isScanning = true;
    
    // Show dialog đang scan
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 16),
            const Text(
              'Waiting for QR Code...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scanning QR code from Firebase',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );

    // Listen cho QR data
    final ref = FirebaseDatabase.instance.ref('sensors/qr_data');
    late final subscription;
    
    subscription = ref.onValue.listen((event) async {
      if (!isScanning || !mounted) return;
      
      if (event.snapshot.exists && event.snapshot.value != null) {
        final qrData = event.snapshot.value.toString();
        
        // Kiểm tra nếu có data hợp lệ
        if (qrData.isNotEmpty && 
            qrData != 'null' && 
            qrData != '""' && 
            qrData != "''") {
          
          print('✅ QR Data received: $qrData');
          
          // Cancel subscription ngay
          isScanning = false;
          await subscription.cancel();
          
          // Set check_qr = false và qr_data = "null" để stop scan
          try {
            await FirebaseDatabase.instance.ref('sensors').update({
              'check_qr': false,
              'qr_data': 'null',
            });
            print('🔴 QR Scan stopped: check_qr = false, qr_data = "null"');
          } catch (e) {
            print('❌ Error setting check_qr: $e');
          }
          
          // Close dialog safely
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          
          // Set SKU từ QR code
          if (mounted) {
            setState(() {
              _rfidUUID = qrData;
              _selectedZone = null;
            });
            
            // Show success
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ QR Code Scanned: $_rfidUUID'),
                backgroundColor: const Color(0xFF8B5CF6),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    });
    
    // Timeout sau 30 giây
    Future.delayed(const Duration(seconds: 30), () async {
      if (!isScanning || !mounted) return;
      
      isScanning = false;
      await subscription.cancel();
      
      // Set check_qr = false và qr_data = "null"
      try {
        await FirebaseDatabase.instance.ref('sensors').update({
          'check_qr': false,
          'qr_data': 'null',
        });
        print('⏱️ Timeout: check_qr = false, qr_data = "null"');
      } catch (e) {
        print('❌ Error: $e');
      }
      
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏱️ QR Scan timeout. Please try again.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
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
                _selectedZone = null;
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
      showErrorSnackTop(context, 'Please enter item name');
      return;
    }

    if (_selectedImage == null) {
      showErrorSnackTop(context, 'Please select or capture a product image');
      return;
    }

    if (_rfidUUID == null || _rfidUUID!.isEmpty) {
      showErrorSnackTop(context, 'Please scan or enter SKU');
      return;
    }

    if (_selectedCategory == null) {
      showErrorSnackTop(context, 'Please select a category');
      return;
    }

    if (_quantityController.text.trim().isEmpty) {
      showErrorSnackTop(context, 'Please enter quantity');
      return;
    }

    if (_costController.text.trim().isEmpty) {
      showErrorSnackTop(context, 'Please enter cost');
      return;
    }

    if (_priceController.text.trim().isEmpty) {
      showErrorSnackTop(context, 'Please enter price');
      return;
    }

    if (_ramController.text.trim().isEmpty) {
      showErrorSnackTop(context, 'Please enter RAM');
      return;
    }

    if (_gpuController.text.trim().isEmpty) {
      showErrorSnackTop(context, 'Please enter GPU');
      return;
    }

    if (_colorController.text.trim().isEmpty) {
      showErrorSnackTop(context, 'Please enter color');
      return;
    }

    if (_processorController.text.trim().isEmpty) {
      showErrorSnackTop(context, 'Please enter processor');
      return;
    }

    // Validate numeric fields
    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      showErrorSnackTop(context, 'Please enter a valid quantity');
      return;
    }

    final cost = double.tryParse(_costController.text.trim());
    if (cost == null || cost <= 0) {
      showErrorSnackTop(context, 'Please enter a valid cost');
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      showErrorSnackTop(context, 'Please enter a valid price');
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
        ram: _ramController.text.trim(),
        date: formattedDate,
        gpu: _gpuController.text.trim(),
        color: _colorController.text.trim(),
        processor: _processorController.text.trim(),
        zone: _selectedZone,
        barcode: _rfidUUID, // Using RFID UUID as barcode for now
        xFileImage: _selectedImage, // Pass XFile for both web and mobile
      );

      // Clear product cache to force refresh
      ProductService.instance.clearCache();

      // Show success message
      if (mounted) {
        showSuccessSnackTop(context, 'Product created successfully!');
        // Navigate back to items page
        Navigator.pop(context, true); // Return true to indicate success
      }

    } catch (e) {
      if (mounted) {
        showErrorSnackTop(context, e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


}
