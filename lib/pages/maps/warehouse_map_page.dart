import 'package:flutter/material.dart';
import '../../services/product_service.dart';
import '../../apis/product_api.dart';

// Model for a shelf/rack in the warehouse
class ShelfRack {
  final String id;
  final String label;
  final String zone; // 'A', 'B', 'C', 'D'
  final int row;
  final int col;
  final List<ProductModel> products;

  ShelfRack({
    required this.id,
    required this.label,
    required this.zone,
    required this.row,
    required this.col,
    required this.products,
  });

  int get totalStock => products.fold(0, (sum, p) => sum + p.quantity);
  int get productCount => products.length;

  String get status {
    if (products.isEmpty) return 'empty';
    if (totalStock > 80) return 'full';
    if (totalStock > 30) return 'normal';
    return 'low';
  }
}

class WarehouseMapPage extends StatefulWidget {
  const WarehouseMapPage({super.key});

  @override
  State<WarehouseMapPage> createState() => _WarehouseMapPageState();
}

class _WarehouseMapPageState extends State<WarehouseMapPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  List<ShelfRack> _shelves = [];
  ShelfRack? _selectedShelf;
  bool _isLoading = true;
  String _selectedZone = 'All';
  final TransformationController _transformController =
      TransformationController();

  final List<String> _zones = ['All', 'A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final response = await GetAllProductsApi.getAllProducts();
      final List<dynamic> productsData = response['data'] ?? [];
      final products = productsData
          .map((json) => ProductModel.fromJson(json))
          .toList();
      _shelves = _distributeToShelves(products);
    } catch (e) {
      _shelves = _distributeToShelves([]);
    }
    setState(() => _isLoading = false);
    _fadeController.forward();
  }

  List<ShelfRack> _distributeToShelves(List<ProductModel> products) {
    final zones = ['A', 'B', 'C', 'D'];
    final List<ShelfRack> shelves = [];
    int productIndex = 0;

    for (final zone in zones) {
      for (int row = 1; row <= 3; row++) {
        for (int col = 1; col <= 4; col++) {
          final List<ProductModel> shelfProducts = [];
          // Put 1-2 products per shelf
          final count = (productIndex < products.length)
              ? (col % 2 == 0 ? 2 : 1)
              : 0;
          for (int i = 0; i < count && productIndex < products.length; i++) {
            shelfProducts.add(products[productIndex]);
            productIndex++;
          }

          shelves.add(
            ShelfRack(
              id: '$zone$row$col',
              label: '$zone-$row$col',
              zone: zone,
              row: row,
              col: col,
              products: shelfProducts,
            ),
          );
        }
      }
    }
    return shelves;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'full':
        return const Color(0xFF3B82F6);
      case 'normal':
        return const Color(0xFF22C55E);
      case 'low':
        return const Color(0xFFF59E0B);
      case 'empty':
        return const Color(0xFF475569);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'full':
        return 'Well Stocked';
      case 'normal':
        return 'Normal';
      case 'low':
        return 'Low Stock';
      case 'empty':
        return 'Empty';
      default:
        return '';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'full':
        return Icons.check_circle;
      case 'normal':
        return Icons.info;
      case 'low':
        return Icons.warning_amber_rounded;
      case 'empty':
        return Icons.remove_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  void _selectShelf(ShelfRack shelf) {
    setState(() => _selectedShelf = shelf);
    _slideController.forward(from: 0);
  }

  void _closeDetails() {
    _slideController.reverse().then((_) {
      setState(() => _selectedShelf = null);
    });
  }

  List<ShelfRack> get _filteredShelves {
    if (_selectedZone == 'All') return _shelves;
    return _shelves.where((s) => s.zone == _selectedZone).toList();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildZoneFilter(),
            _buildSummaryRow(),
            Expanded(
              child: _isLoading ? _buildLoadingState() : _buildFloorPlan(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final totalProducts = _shelves.fold(0, (sum, s) => sum + s.productCount);
    final totalStock = _shelves.fold(0, (sum, s) => sum + s.totalStock);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF334155),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Warehouse Layout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '$totalProducts products • $totalStock total stock',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
          ),
          _buildLegendButton(),
        ],
      ),
    );
  }

  Widget _buildLegendButton() {
    return GestureDetector(
      onTap: _showLegend,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6).withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.info_outline,
          color: Color(0xFF3B82F6),
          size: 20,
        ),
      ),
    );
  }

  void _showLegend() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shelf Status Legend',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _legendItem(
              const Color(0xFF3B82F6),
              'Well Stocked',
              'More than 80 items',
            ),
            _legendItem(const Color(0xFF22C55E), 'Normal', '31 - 80 items'),
            _legendItem(const Color(0xFFF59E0B), 'Low Stock', '1 - 30 items'),
            _legendItem(const Color(0xFF475569), 'Empty', 'No items'),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.5)),
            ),
            child: Icon(Icons.inventory_2, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                desc,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneFilter() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _zones.length,
        itemBuilder: (context, index) {
          final zone = _zones[index];
          final isSelected = zone == _selectedZone;
          return GestureDetector(
            onTap: () => setState(() => _selectedZone = zone),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                      )
                    : null,
                color: isSelected ? null : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : const Color(0xFF334155),
                ),
              ),
              child: Text(
                zone == 'All' ? 'All Zones' : 'Zone $zone',
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[400],
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow() {
    final filtered = _filteredShelves;
    final occupied = filtered.where((s) => s.products.isNotEmpty).length;
    final empty = filtered.where((s) => s.products.isEmpty).length;
    final lowStock = filtered.where((s) => s.status == 'low').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          _summaryChip(
            Icons.grid_view,
            '$occupied',
            'Occupied',
            const Color(0xFF22C55E),
          ),
          const SizedBox(width: 8),
          _summaryChip(
            Icons.inbox_outlined,
            '$empty',
            'Empty',
            const Color(0xFF475569),
          ),
          const SizedBox(width: 8),
          _summaryChip(
            Icons.warning_amber,
            '$lowStock',
            'Low',
            const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF3B82F6), strokeWidth: 3),
          SizedBox(height: 20),
          Text(
            'Loading warehouse layout...',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildFloorPlan() {
    final shelvesByZone = <String, List<ShelfRack>>{};
    for (final shelf in _filteredShelves) {
      shelvesByZone.putIfAbsent(shelf.zone, () => []).add(shelf);
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Stack(
        children: [
          // Floor plan grid
          InteractiveViewer(
            transformationController: _transformController,
            minScale: 0.5,
            maxScale: 3.0,
            boundaryMargin: const EdgeInsets.all(80),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Warehouse boundary
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1423),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF1E3A5F).withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Entrance indicator
                          _buildEntranceIndicator(),
                          const SizedBox(height: 12),
                          // Zones
                          ...shelvesByZone.entries.map(
                            (entry) =>
                                _buildZoneSection(entry.key, entry.value),
                          ),
                          const SizedBox(height: 12),
                          // Exit indicator
                          _buildExitArea(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 260),
                  ],
                ),
              ),
            ),
          ),

          // Selected shelf detail panel
          if (_selectedShelf != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SlideTransition(
                position: _slideAnimation,
                child: _buildDetailPanel(_selectedShelf!),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEntranceIndicator() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3B82F6).withOpacity(0.1),
            const Color(0xFF3B82F6).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF3B82F6).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.door_front_door_outlined,
            color: const Color(0xFF3B82F6).withOpacity(0.7),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'ENTRANCE',
            style: TextStyle(
              color: const Color(0xFF3B82F6).withOpacity(0.7),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExitArea() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF334155).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF475569).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            color: Colors.grey[600],
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'LOADING DOCK',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneSection(String zone, List<ShelfRack> shelves) {
    final zoneColors = {
      'A': const Color(0xFF3B82F6),
      'B': const Color(0xFF8B5CF6),
      'C': const Color(0xFF06B6D4),
      'D': const Color(0xFFEC4899),
    };
    final color = zoneColors[zone] ?? const Color(0xFF3B82F6);

    // Group by row
    final rows = <int, List<ShelfRack>>{};
    for (final shelf in shelves) {
      rows.putIfAbsent(shelf.row, () => []).add(shelf);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Zone header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ZONE $zone',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${shelves.where((s) => s.products.isNotEmpty).length}/${shelves.length} shelves occupied',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Shelf rows
          ...rows.entries.map((entry) => _buildShelfRow(entry.value, color)),
        ],
      ),
    );
  }

  Widget _buildShelfRow(List<ShelfRack> shelves, Color zoneColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          // Aisle label
          SizedBox(
            width: 20,
            child: RotatedBox(
              quarterTurns: -1,
              child: Text(
                'R${shelves.first.row}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          ...shelves.map(
            (shelf) => Expanded(child: _buildShelfCell(shelf, zoneColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildShelfCell(ShelfRack shelf, Color zoneColor) {
    final statusColor = _getStatusColor(shelf.status);
    final isSelected = _selectedShelf?.id == shelf.id;

    return GestureDetector(
      onTap: () => _selectShelf(shelf),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.all(6),
            height: 62,
            decoration: BoxDecoration(
              color: isSelected
                  ? statusColor.withOpacity(0.2)
                  : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? statusColor
                    : statusColor.withOpacity(
                        shelf.status == 'low'
                            ? 0.3 + _pulseAnimation.value * 0.3
                            : 0.2,
                      ),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Shelf icon
                Icon(
                  shelf.products.isEmpty
                      ? Icons.inbox_outlined
                      : Icons.inventory_2,
                  color: statusColor,
                  size: 16,
                ),
                const SizedBox(height: 2),
                // Label
                Text(
                  shelf.label,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // Stock count
                if (shelf.totalStock > 0)
                  Text(
                    '${shelf.totalStock}',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailPanel(ShelfRack shelf) {
    final statusColor = _getStatusColor(shelf.status);

    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF162032)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: statusColor.withOpacity(0.4), width: 2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.inventory_2_rounded,
                          color: statusColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shelf ${shelf.label}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  _getStatusIcon(shelf.status),
                                  color: statusColor,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getStatusLabel(shelf.status),
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _closeDetails,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    children: [
                      _detailStat(
                        'Products',
                        shelf.productCount.toString(),
                        Icons.category,
                        const Color(0xFF3B82F6),
                      ),
                      const SizedBox(width: 10),
                      _detailStat(
                        'Total Stock',
                        shelf.totalStock.toString(),
                        Icons.stacked_bar_chart,
                        const Color(0xFF8B5CF6),
                      ),
                      const SizedBox(width: 10),
                      _detailStat(
                        'Zone',
                        shelf.zone,
                        Icons.grid_view,
                        const Color(0xFF06B6D4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Products list
                  if (shelf.products.isNotEmpty) ...[
                    Text(
                      'Products on this shelf',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 65,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: shelf.products.length,
                        itemBuilder: (context, index) {
                          final product = shelf.products[index];
                          return Container(
                            width: 150,
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF334155),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF334155),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: product.image.startsWith('http')
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          child: Image.network(
                                            product.image,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                                  Icons.laptop,
                                                  color: Color(0xFF64748B),
                                                  size: 18,
                                                ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.laptop,
                                          color: Color(0xFF64748B),
                                          size: 18,
                                        ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Qty: ${product.quantity}',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ] else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'This shelf is empty',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
