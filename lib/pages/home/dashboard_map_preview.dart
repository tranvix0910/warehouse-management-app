import 'package:flutter/material.dart';
import '../maps/warehouse_map_page.dart';

class DashboardMapPreview extends StatefulWidget {
  const DashboardMapPreview({super.key});

  @override
  State<DashboardMapPreview> createState() => _DashboardMapPreviewState();
}

class _DashboardMapPreviewState extends State<DashboardMapPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
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
            height: 180,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A2744), Color(0xFF162032)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(
                  0xFF3B82F6,
                ).withOpacity(_glowAnimation.value * 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFF3B82F6,
                  ).withOpacity(_glowAnimation.value * 0.08),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Mini shelf grid
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 50),
                    child: _buildMiniShelfGrid(),
                  ),

                  // Gradient overlay at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF0F172A).withOpacity(0.98),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Title & expand button
                  Positioned(
                    bottom: 12,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.warehouse_rounded,
                                color: Color(0xFF3B82F6),
                                size: 16,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Warehouse Layout',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'View shelf map & stock placement',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF3B82F6).withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.open_in_full,
                                color: Color(0xFF3B82F6),
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Expand',
                                style: TextStyle(
                                  color: Color(0xFF3B82F6),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildMiniShelfGrid() {
    // Mini representation of warehouse shelves
    final shelfData = [
      // Zone A row
      [
        {'status': 'full'},
        {'status': 'normal'},
        {'status': 'full'},
        {'status': 'low'},
        {'status': 'normal'},
        {'status': 'full'},
        {'status': 'empty'},
        {'status': 'normal'},
      ],
      // Zone B row
      [
        {'status': 'normal'},
        {'status': 'full'},
        {'status': 'low'},
        {'status': 'normal'},
        {'status': 'empty'},
        {'status': 'full'},
        {'status': 'normal'},
        {'status': 'full'},
      ],
      // Zone C row
      [
        {'status': 'empty'},
        {'status': 'normal'},
        {'status': 'full'},
        {'status': 'normal'},
        {'status': 'full'},
        {'status': 'low'},
        {'status': 'normal'},
        {'status': 'empty'},
      ],
    ];

    final statusColors = {
      'full': const Color(0xFF3B82F6),
      'normal': const Color(0xFF22C55E),
      'low': const Color(0xFFF59E0B),
      'empty': const Color(0xFF475569).withOpacity(0.4),
    };

    return Column(
      children: shelfData.asMap().entries.map((rowEntry) {
        final rowIndex = rowEntry.key;
        final row = rowEntry.value;
        final zoneLabel = ['A', 'B', 'C'][rowIndex];

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                // Zone label
                SizedBox(
                  width: 16,
                  child: Text(
                    zoneLabel,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...row.map((shelf) {
                  final color =
                      statusColors[shelf['status']] ?? const Color(0xFF475569);
                  return Expanded(
                    child: AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        final isLow = shelf['status'] == 'low';
                        return Container(
                          margin: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: color.withOpacity(
                              isLow ? 0.3 + _glowAnimation.value * 0.3 : 0.3,
                            ),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: color.withOpacity(
                                isLow ? 0.5 + _glowAnimation.value * 0.3 : 0.4,
                              ),
                              width: 0.5,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              shelf['status'] == 'empty'
                                  ? Icons.remove
                                  : Icons.inventory_2,
                              color: color.withOpacity(0.7),
                              size: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
