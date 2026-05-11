import 'package:flutter/material.dart';
import '../maps/warehouse_map_page.dart';
import '../../services/product_service.dart';

class DashboardMapPreview extends StatefulWidget {
  final List<ProductModel>? products;
  const DashboardMapPreview({super.key, this.products});

  @override
  State<DashboardMapPreview> createState() => _DashboardMapPreviewState();
}

class _DashboardMapPreviewState extends State<DashboardMapPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  List<ProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.products != null) {
      _products = widget.products!;
      _isLoading = false;
    } else {
      _loadProducts();
    }
  }

  @override
  void didUpdateWidget(DashboardMapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.products != null) {
      setState(() {
        _products = widget.products!;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ProductService.instance.getProducts();
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToFullMap() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WarehouseMapPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return GestureDetector(
          onTap: _navigateToFullMap,
          child: Container(
            height: 250,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(_glowAnimation.value * 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  // Main Content
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.location_on, color: Color(0xFF3B82F6), size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Warehouse Layout',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                              ),
                              child: const Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Color(0xFF3B82F6),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                              : Row(
                                  children: [
                                    Expanded(child: _buildZoneCard('zone1', const Color(0xFF3B82F6))),
                                    const SizedBox(width: 12),
                                    Expanded(child: _buildZoneCard('zone2', const Color(0xFF10B981))),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.info_outline, color: Color(0xFF64748B), size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Tap to view detailed 3D shelf map',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.arrow_forward_ios, color: Color(0xFF3B82F6), size: 12),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildZoneCard(String zoneName, Color color) {
    final zoneProducts = _products.where((p) => p.zone == zoneName).toList();
    final count = zoneProducts.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                zoneName.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Products',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 6),
          if (count > 0)
            SizedBox(
              height: 20,
              child: Stack(
                children: zoneProducts.take(3).toList().asMap().entries.map((entry) {
                  return Positioned(
                    left: entry.key * 12.0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF0F172A), width: 1.5),
                        color: color.withOpacity(0.2),
                      ),
                      child: ClipOval(
                        child: entry.value.image.isNotEmpty
                            ? Image.network(entry.value.image, fit: BoxFit.cover)
                            : Icon(Icons.inventory_2, size: 10, color: color),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

