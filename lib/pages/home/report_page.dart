import 'package:flutter/material.dart';

class ReportItem {
  final String name;
  final String sku;
  final int stock;
  final int daysInStock;
  final String status;

  ReportItem({
    required this.name,
    required this.sku,
    required this.stock,
    required this.daysInStock,
    required this.status,
  });
}

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int selectedTabIndex = 0;
  
  final List<ReportItem> oldStockItems = [
    ReportItem(name: 'Microsoft Surface 4', sku: 'UEPYMGDO', stock: 80, daysInStock: 15, status: 'old'),
    ReportItem(name: 'Lenovo ThinkPad', sku: 'NNEUUUKXCL', stock: 50, daysInStock: 12, status: 'old'),
    ReportItem(name: 'Apple MacBook Pro 14', sku: 'SMXAPGAID', stock: 45, daysInStock: 9, status: 'old'),
  ];

  final List<ReportItem> outOfStockItems = [
    ReportItem(name: 'Samsung Galaxy Tab', sku: 'SGTTAB001', stock: 0, daysInStock: 0, status: 'out'),
    ReportItem(name: 'iPad Pro 12.9', sku: 'IPADPRO12', stock: 0, daysInStock: 0, status: 'out'),
  ];

  final List<ReportItem> lowStockItems = [
    ReportItem(name: 'Hp monoblock 12', sku: 'IQHPVMSD', stock: 15, daysInStock: 5, status: 'low'),
    ReportItem(name: 'Dell XPS 13', sku: 'DELLXPS13', stock: 8, daysInStock: 3, status: 'low'),
    ReportItem(name: 'Asus VivoBook', sku: 'ASUSVIVO1', stock: 12, daysInStock: 2, status: 'low'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Reports',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () {
              _showDateRangePicker();
            },
            icon: const Icon(
              Icons.date_range,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              _exportToCSV();
            },
            icon: const Icon(
              Icons.download,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dashboard Overview Cards
            const Text(
              'Analytics Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Overview Cards
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    title: 'Old Stock',
                    count: oldStockItems.length.toString(),
                    subtitle: '>7 days',
                    color: const Color(0xFFFF8C00),
                    icon: Icons.inventory,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOverviewCard(
                    title: 'Out of Stock',
                    count: outOfStockItems.length.toString(),
                    subtitle: 'Need restock',
                    color: const Color(0xFFFF6B6B),
                    icon: Icons.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildOverviewCard(
                    title: 'Low Stock',
                    count: lowStockItems.length.toString(),
                    subtitle: 'Low quantity',
                    color: const Color(0xFFFFD93D),
                    icon: Icons.trending_down,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOverviewCard(
                    title: 'Total Items',
                    count: '${oldStockItems.length + outOfStockItems.length + lowStockItems.length}',
                    subtitle: 'Need attention',
                    color: const Color(0xFF3B82F6),
                    icon: Icons.analytics,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Tab Navigation
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      title: 'Old Stock',
                      index: 0,
                      isSelected: selectedTabIndex == 0,
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      title: 'Out of Stock',
                      index: 1,
                      isSelected: selectedTabIndex == 1,
                    ),
                  ),
                  Expanded(
                    child: _buildTabButton(
                      title: 'Low Stock',
                      index: 2,
                      isSelected: selectedTabIndex == 2,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Content based on selected tab
            _buildTabContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard({
    required String title,
    required String count,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    List<ReportItem> items;
    String emptyMessage;
    
    switch (selectedTabIndex) {
      case 0:
        items = oldStockItems;
        emptyMessage = 'No old stock items';
        break;
      case 1:
        items = outOfStockItems;
        emptyMessage = 'No out of stock items';
        break;
      case 2:
        items = lowStockItems;
        emptyMessage = 'No low stock items';
        break;
      default:
        items = [];
        emptyMessage = '';
    }

    if (items.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            emptyMessage,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Column(
      children: items.map((item) => _buildReportItem(item)).toList(),
    );
  }

  Widget _buildReportItem(ReportItem item) {
    Color statusColor;
    String statusText;
    
    switch (item.status) {
      case 'old':
        statusColor = const Color(0xFFFF8C00);
        statusText = '${item.daysInStock} days';
        break;
      case 'out':
        statusColor = const Color(0xFFFF6B6B);
        statusText = 'Out of stock';
        break;
      case 'low':
        statusColor = const Color(0xFFFFD93D);
        statusText = '${item.stock} left';
        break;
      default:
        statusColor = Colors.grey;
        statusText = '';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getStatusIcon(item.status),
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'SKU: ${item.sku}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                if (item.stock > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Stock: ${item.stock}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'old':
        return Icons.schedule;
      case 'out':
        return Icons.warning;
      case 'low':
        return Icons.trending_down;
      default:
        return Icons.info;
    }
  }

  void _showDateRangePicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Select Date Range',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Date range selection feature will be updated soon.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );
  }

  void _exportToCSV() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Export CSV',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Exporting CSV report...\nThis feature will be completed in the next version.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF3B82F6)),
            ),
          ),
        ],
      ),
    );
  }
}
