import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'suppliers_page.dart';
import 'items_selection_page.dart';
import '../../apis/add_transaction_api.dart';
import '../../services/product_service.dart';
import '../../services/barcode_scanner_service.dart';
import '../../utils/snack_bar.dart';

class StockInPage extends StatefulWidget {
  const StockInPage({super.key});

  @override
  State<StockInPage> createState() => _StockInPageState();
}

class _StockInPageState extends State<StockInPage> {
  DateTime selectedDate = DateTime.now();
  String? selectedSupplier;
  String notes = '';
  List<Map<String, dynamic>> selectedItems = [];
  bool _isSaving = false;

  String _scanMode = 'RFID';
  StreamSubscription? _rfidSubscription;
  StreamSubscription? _qrSubscription;
  DateTime? _lastRfidScanTime;

  @override
  void initState() {
    super.initState();
    _startRfidScanning();
    _switchScanMode('RFID');
  }

  @override
  void dispose() {
    _rfidSubscription?.cancel();
    _qrSubscription?.cancel();
    try {
      FirebaseDatabase.instance.ref('sensors').update({
        'check_rfid': false,
        'check_qr': false,
        'uid_1': "",
        'uid_2': "",
        'qr_data': "null",
      });
    } catch (_) {}
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
          'Stock In',
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
                  // Stock In Date
                  _buildDateSection(),

                  const SizedBox(height: 24),

                  // Supplier
                  _buildSupplierSection(),

                  const SizedBox(height: 24),

                  // Notes
                  _buildNotesSection(),

                  const SizedBox(height: 24),

                  // Scan QR to add items
                  _buildScanSection(),

                  const SizedBox(height: 24),

                  // Items
                  _buildItemsSection(),
                ],
              ),
            ),
          ),

          // Save Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveStockIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Save',
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

  Widget _buildDateSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Stock In Date',
            style: TextStyle(
              color: Color(0xFF3B82F6),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          GestureDetector(
            onTap: _selectDate,
            child: Text(
              DateFormat('MMM dd, yyyy').format(selectedDate),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierSection() {
    return GestureDetector(
      onTap: _selectSupplier,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Supplier',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Text(
                  selectedSupplier ?? 'Choose',
                  style: TextStyle(
                    color: selectedSupplier != null
                        ? Colors.white
                        : Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return GestureDetector(
      onTap: _editNotes,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Notes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Row(
              children: [
                Text(
                  notes.isEmpty ? '-' : notes,
                  style: TextStyle(
                    color: notes.isEmpty ? Colors.grey : Colors.white,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[600],
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Column(
        children: [
          // Items Header (tap to open selection)
          InkWell(
            onTap: _selectProducts,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Items',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _totalSelectedQuantity().toString(),
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Items Content (compact list with in-place steppers like screenshot)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: selectedItems.isEmpty
                ? Column(
                    children: [
                      const SizedBox(height: 8),
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Select products',
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                    ],
                  )
                : Column(
                    children: selectedItems.map((item) {
                      final int qty = (item['quantity'] is num)
                          ? (item['quantity'] as num).toInt()
                          : int.tryParse('${item['quantity']}') ?? 0;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child:
                                  (item['image'] is String &&
                                      (item['image'] as String).startsWith(
                                        'http',
                                      ))
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        item['image'],
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.laptop,
                                      color: Color(0xFF64748B),
                                      size: 18,
                                    ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Available: ${item['availableStock'] ?? 0}',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _MiniStepper(
                              quantity: qty,
                              onDecrement: () {
                                setState(() {
                                  final next = qty - 1;
                                  if (next <= 0) {
                                    selectedItems.remove(item);
                                  } else {
                                    item['quantity'] = next;
                                  }
                                });
                              },
                              onIncrement: () {
                                setState(() {
                                  item['quantity'] = qty + 1;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  int _totalSelectedQuantity() {
    int total = 0;
    for (final item in selectedItems) {
      final dynamic q = item['quantity'];
      if (q is num)
        total += q.toInt();
      else
        total += int.tryParse('$q') ?? 0;
    }
    return total;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
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
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _selectSupplier() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SuppliersPage()),
    ).then((selectedSupplierData) {
      if (selectedSupplierData != null) {
        setState(() {
          selectedSupplier = selectedSupplierData['name'];
        });
      }
    });
  }

  void _editNotes() {
    showDialog(
      context: context,
      builder: (context) {
        String tempNotes = notes;
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Notes', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: TextEditingController(text: notes),
            onChanged: (value) => tempNotes = value,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter notes...',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  notes = tempNotes;
                });
                Navigator.pop(context);
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Color(0xFF3B82F6)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _selectProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ItemsSelectionPage(preSelectedItems: selectedItems),
      ),
    ).then((selectedItemsData) {
      if (selectedItemsData != null) {
        setState(() {
          selectedItems = List<Map<String, dynamic>>.from(selectedItemsData);
        });
      }
    });
  }

  // ========================
  // QR / Barcode Scan for Stock In
  // ========================

  void _startRfidScanning() async {
    try {
      await FirebaseDatabase.instance.ref('sensors').update({
        'check_rfid': true,
        'uid_1': "",
        'uid_2': "",
      });
    } catch (_) {}

    final ref = FirebaseDatabase.instance.ref('sensors');
    _rfidSubscription = ref.onValue.listen((event) async {
      if (!mounted) return;
      if (event.snapshot.exists && event.snapshot.value != null) {
        final Map<dynamic, dynamic> data = event.snapshot.value as Map<dynamic, dynamic>;
        String? rfidUid;

        if (data.containsKey('uid_1') && data['uid_1'].toString().isNotEmpty && 
            data['uid_1'].toString() != 'null' && data['uid_1'].toString() != '""') {
          rfidUid = data['uid_1'].toString();
        } else if (data.containsKey('uid_2') && data['uid_2'].toString().isNotEmpty && 
            data['uid_2'].toString() != 'null' && data['uid_2'].toString() != '""') {
          rfidUid = data['uid_2'].toString();
        }

        if (rfidUid != null) {
          final now = DateTime.now();
          if (_lastRfidScanTime != null && now.difference(_lastRfidScanTime!).inSeconds < 2) {
            return;
          }
          _lastRfidScanTime = now;

          try {
            await FirebaseDatabase.instance.ref('sensors').update({
              'uid_1': "",
              'uid_2': "",
              'check_rfid': false,
            });
          } catch (_) {}

          if (mounted) await _findAndAddProduct(rfidUid);

          Future.delayed(const Duration(seconds: 2), () async {
            if (!mounted) return;
            try {
              await FirebaseDatabase.instance.ref('sensors').update({
                'check_rfid': true,
              });
            } catch (_) {}
          });
        }
      }
    });
  }

  void _switchScanMode(String mode) async {
    setState(() {
      _scanMode = mode;
    });

    // Cancel existing QR subscription if switching
    await _qrSubscription?.cancel();

    if (mode == 'QR') {
      try {
        await FirebaseDatabase.instance.ref('sensors').update({
          'check_qr': true,
          'qr_data': 'null',
        });
      } catch (_) {}

      final ref = FirebaseDatabase.instance.ref('sensors/qr_data');
      _qrSubscription = ref.onValue.listen((event) async {
        if (!mounted || _scanMode != 'QR') return;
        if (event.snapshot.exists && event.snapshot.value != null) {
          final qrData = event.snapshot.value.toString();
          if (qrData.isNotEmpty &&
              qrData != 'null' &&
              qrData != '""' &&
              qrData != "''") {
            try {
              await FirebaseDatabase.instance.ref('sensors').update({
                'qr_data': 'null',
              });
            } catch (_) {}

            if (mounted) await _findAndAddProduct(qrData);
          }
        }
      });
    } else {
      // If we switch away from QR (to RFID or Camera), turn off QR but keep RFID check_rfid true
      try {
        await FirebaseDatabase.instance.ref('sensors').update({
          'check_qr': false,
        });
      } catch (_) {}
    }
  }

  Widget _buildScanSection() {
    final Color rfidColor = const Color(0xFF3B82F6);
    final Color qrColor = const Color(0xFF8B5CF6);
    final Color cameraColor = const Color(0xFFF59E0B);

    Color activeColor = rfidColor;
    if (_scanMode == 'QR') activeColor = qrColor;
    if (_scanMode == 'Camera') activeColor = cameraColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            activeColor.withOpacity(0.1),
            const Color(0xFF3B82F6).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: activeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _scanMode == 'RFID' 
                      ? Icons.credit_card 
                      : (_scanMode == 'QR' ? Icons.qr_code : Icons.qr_code_scanner),
                  color: activeColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _scanMode == 'RFID'
                          ? 'RFID Scan Active'
                          : (_scanMode == 'QR' ? 'QR & RFID Scan Active' : 'Camera Scan Mode (RFID Active)'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _scanMode == 'RFID'
                          ? 'Scan RFID cards to add items'
                          : (_scanMode == 'QR' ? 'Scan QR codes or RFID cards to add items' : 'Tap Camera Scan below or use RFID'),
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildScanButton(
                  icon: Icons.qr_code_scanner,
                  label: 'Camera Scan',
                  color: cameraColor,
                  isActive: _scanMode == 'Camera',
                  onTap: () {
                    _switchScanMode('Camera');
                    _scanBarcodeForStockIn();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScanButton(
                  icon: Icons.qr_code,
                  label: 'QR (Firebase)',
                  color: qrColor,
                  isActive: _scanMode == 'QR',
                  onTap: () => _switchScanMode('QR'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScanButton(
                  icon: Icons.credit_card,
                  label: 'RFID',
                  color: rfidColor,
                  isActive: _scanMode == 'RFID',
                  onTap: () => _switchScanMode('RFID'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.25) : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? color : color.withOpacity(0.15),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? color : color.withOpacity(0.6), size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? color : color.withOpacity(0.6),
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _scanBarcodeForStockIn() async {
    if (kIsWeb) {
      showErrorSnackTop(context, 'Barcode scanning is not supported on web');
      return;
    }

    final result = await BarcodeScannerService.scanBarcode(context);
    if (result != null && mounted) {
      await _findAndAddProduct(result);
    }
  }

  // Find product by scanned code (SKU/barcode) and add to selectedItems
  Future<void> _findAndAddProduct(String scannedCode) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        backgroundColor: Color(0xFF1E293B),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFF3B82F6)),
            SizedBox(height: 16),
            Text(
              'Finding product...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );

    try {
      // Get all products and find by SKU match
      final products = await ProductService.instance.getProducts(
        forceRefresh: true,
      );

      if (mounted && Navigator.canPop(context)) Navigator.pop(context);

      final matchedProduct = products.cast<ProductModel?>().firstWhere(
        (p) =>
            p!.sku.toLowerCase() == scannedCode.toLowerCase() ||
            p.sku == scannedCode,
        orElse: () => null,
      );

      if (matchedProduct == null) {
        if (mounted) {
          _showProductNotFoundDialog(scannedCode);
        }
        return;
      }

      // Check if already added
      final existingIdx = selectedItems.indexWhere(
        (item) => item['productId'] == matchedProduct.id,
      );

      if (existingIdx >= 0) {
        // Already exists, auto-increment quantity by 1
        final currentQty = (selectedItems[existingIdx]['quantity'] is num)
            ? (selectedItems[existingIdx]['quantity'] as num).toInt()
            : int.tryParse('${selectedItems[existingIdx]['quantity']}') ?? 0;
        final newQty = currentQty + 1;
        setState(() {
          selectedItems[existingIdx]['quantity'] = newQty;
        });
        if (mounted) {
          showSuccessSnackTop(
            context,
            '${matchedProduct.name} quantity increased to $newQty',
          );
        }
      } else {
        // First time adding, add with default quantity of 1
        setState(() {
          selectedItems.add({
            'productId': matchedProduct.id,
            'name': matchedProduct.name,
            'sku': matchedProduct.sku,
            'quantity': 1,
            'image': matchedProduct.image,
            'price': matchedProduct.price,
            'cost': matchedProduct.cost,
            'availableStock': matchedProduct.quantity,
          });
        });
        if (mounted) {
          showSuccessSnackTop(
            context,
            '${matchedProduct.name} added (qty: 1)',
          );
        }
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) {
        showErrorSnackTop(
          context,
          'Error finding product: ${e.toString().replaceFirst("Exception: ", "")}',
        );
      }
    }
  }

  void _showProductNotFoundDialog(String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.search_off,
                color: Color(0xFFEF4444),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Product Not Found',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No product matches the scanned code:',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure the product exists and the SKU matches.',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: Color(0xFF3B82F6))),
          ),
        ],
      ),
    );
  }

  void _showProductFoundDialog(ProductModel product) {
    final TextEditingController qtyController = TextEditingController(
      text: '1',
    );
    bool isValid = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Product Found',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product info card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
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
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.laptop,
                                    color: Color(0xFF64748B),
                                    size: 22,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.laptop,
                                color: Color(0xFF64748B),
                                size: 22,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'SKU: ${product.sku}',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Available stock badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.inventory_2,
                        color: Color(0xFF10B981),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Available: ${product.quantity}',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                // Quantity input
                TextField(
                  controller: qtyController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (val) {
                    final intVal = int.tryParse(val) ?? 0;
                    setDialogState(() {
                      isValid = intVal > 0;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Quantity to stock in',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF334155)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF3B82F6)),
                    ),
                    errorText: !isValid && qtyController.text.isNotEmpty
                        ? 'Must be greater than 0'
                        : null,
                    errorStyle: const TextStyle(color: Color(0xFFEF4444)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: isValid
                    ? () {
                        final qty = int.tryParse(qtyController.text) ?? 1;
                        setState(() {
                          selectedItems.add({
                            'productId': product.id,
                            'name': product.name,
                            'sku': product.sku,
                            'quantity': qty,
                            'image': product.image,
                            'price': product.price,
                            'cost': product.cost,
                            'availableStock': product.quantity,
                          });
                        });
                        Navigator.pop(ctx);
                        showSuccessSnackTop(
                          context,
                          '${product.name} added (qty: $qty)',
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Add to Stock In'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUpdateQuantityDialog(ProductModel product, int existingIdx) {
    final currentQty = (selectedItems[existingIdx]['quantity'] is num)
        ? (selectedItems[existingIdx]['quantity'] as num).toInt()
        : int.tryParse('${selectedItems[existingIdx]['quantity']}') ?? 0;
    final TextEditingController qtyController = TextEditingController(
      text: currentQty.toString(),
    );
    bool isValid = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Product Already Added',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${product.name} is already in the list.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (val) {
                    final intVal = int.tryParse(val) ?? 0;
                    setDialogState(() {
                      isValid = intVal > 0;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Update quantity',
                    labelStyle: TextStyle(color: Colors.grey[400]),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF334155)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF3B82F6)),
                    ),
                    errorText: !isValid && qtyController.text.isNotEmpty
                        ? 'Must be greater than 0'
                        : null,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: isValid
                    ? () {
                        final qty = int.tryParse(qtyController.text) ?? 1;
                        setState(() {
                          selectedItems[existingIdx]['quantity'] = qty;
                        });
                        Navigator.pop(ctx);
                        showSuccessSnackTop(
                          context,
                          '${product.name} quantity updated to $qty',
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Update'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveStockIn() async {
    if (selectedSupplier == null) {
      if (mounted) {
        showErrorSnackTop(context, 'Please select a supplier');
      }
      return;
    }

    if (selectedItems.isEmpty) {
      if (mounted) {
        showErrorSnackTop(context, 'Please select at least one product');
      }
      return;
    }

    // Validate quantities
    for (final item in selectedItems) {
      final qty = (item['quantity'] is num)
          ? (item['quantity'] as num).toInt()
          : int.tryParse('${item['quantity']}') ?? 0;

      if (qty <= 0) {
        if (mounted) {
          showErrorSnackTop(
            context,
            'Please set valid quantity for ${item['name']}',
          );
        }
        return;
      }
    }

    try {
      setState(() {
        _isSaving = true;
      });

      // Transform items to required API shape and validate product ids
      final List<Map<String, dynamic>> itemsForApi = selectedItems.map((item) {
        final dynamic pid =
            item['productId'] ?? item['product'] ?? item['_id'] ?? item['id'];
        final dynamic qty = item['quantity'];
        return {
          'product': pid,
          'quantity': (qty is num)
              ? qty.toInt()
              : int.tryParse(qty?.toString() ?? '0') ?? 0,
        };
      }).toList();

      final hasInvalid = itemsForApi.any(
        (i) => i['product'] == null || (i['quantity'] as int) <= 0,
      );
      if (hasInvalid) {
        throw Exception(
          'Invalid selected items. Please reselect products and quantities.',
        );
      }

      final response = await AddTransactionApi.createStockIn(
        supplier: selectedSupplier!,
        note: notes.isEmpty ? null : notes,
        date: selectedDate,
        items: itemsForApi,
      );

      if (mounted) {
        // ignore: use_build_context_synchronously
        showSuccessSnackTop(
          context,
          response['message'] ?? 'Transaction created successfully',
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        showErrorSnackTop(
          context,
          e.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}

class _MiniStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _MiniStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MiniBtn(icon: Icons.remove, onPressed: onDecrement),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              quantity.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _MiniBtn(icon: Icons.add, onPressed: onIncrement),
        ],
      ),
    );
  }
}

class _MiniBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MiniBtn({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}
