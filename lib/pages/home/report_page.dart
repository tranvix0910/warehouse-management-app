import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../services/export_service.dart';
import '../../utils/snack_bar.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reportNotifierProvider.notifier).loadReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportNotifierProvider);

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
          if (reportState.startDate != null || reportState.endDate != null)
            IconButton(
              onPressed: () {
                ref.read(reportNotifierProvider.notifier).clearDateRange();
              },
              icon: const Icon(Icons.clear, color: Colors.orange),
              tooltip: 'Clear date filter',
            ),
          IconButton(
            onPressed: () => _showDateRangePicker(context),
            icon: Icon(
              Icons.date_range,
              color: reportState.startDate != null ? Colors.green : Colors.white,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.download, color: Colors.white),
            color: const Color(0xFF1E293B),
            onSelected: (value) => _handleExport(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, color: Colors.green, size: 20),
                    SizedBox(width: 12),
                    Text('Export to CSV', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Export to PDF', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: reportState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : (reportState.errorMessage != null)
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        reportState.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.read(reportNotifierProvider.notifier).loadReports(),
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref.read(reportNotifierProvider.notifier).loadReports(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (reportState.startDate != null || reportState.endDate != null)
                          _buildDateRangeIndicator(reportState),
                        
                        const Text(
                          'Analytics Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _buildOverviewCard(
                                title: 'Old Stock',
                                count: reportState.summary.oldStockCount.toString(),
                                subtitle: '>30 days',
                                color: const Color(0xFFFF8C00),
                                icon: Icons.inventory,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildOverviewCard(
                                title: 'Out of Stock',
                                count: reportState.summary.outOfStockCount.toString(),
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
                                count: reportState.summary.lowStockCount.toString(),
                                subtitle: 'Low quantity',
                                color: const Color(0xFFFFD93D),
                                icon: Icons.trending_down,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildOverviewCard(
                                title: 'Total Items',
                                count: reportState.summary.totalProductCount.toString(),
                                subtitle: 'Need attention',
                                color: const Color(0xFF3B82F6),
                                icon: Icons.analytics,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
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
                                  count: reportState.oldStockItems.length,
                                ),
                              ),
                              Expanded(
                                child: _buildTabButton(
                                  title: 'Out of Stock',
                                  index: 1,
                                  isSelected: selectedTabIndex == 1,
                                  count: reportState.outOfStockItems.length,
                                ),
                              ),
                              Expanded(
                                child: _buildTabButton(
                                  title: 'Low Stock',
                                  index: 2,
                                  isSelected: selectedTabIndex == 2,
                                  count: reportState.lowStockItems.length,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        _buildTabContent(reportState),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildDateRangeIndicator(ReportState reportState) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withAlpha(51),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3B82F6).withAlpha(128)),
      ),
      child: Row(
        children: [
          const Icon(Icons.date_range, color: Color(0xFF3B82F6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Date Range: ${reportState.startDate != null ? dateFormat.format(reportState.startDate!) : 'Any'} - ${reportState.endDate != null ? dateFormat.format(reportState.endDate!) : 'Any'}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
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
        border: Border.all(color: color.withAlpha(77)),
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
    required int count,
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
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '($count)',
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(ReportState reportState) {
    List<ReportItem> items;
    String emptyMessage;
    
    switch (selectedTabIndex) {
      case 0:
        items = reportState.oldStockItems;
        emptyMessage = 'No old stock items';
        break;
      case 1:
        items = reportState.outOfStockItems;
        emptyMessage = 'No out of stock items';
        break;
      case 2:
        items = reportState.lowStockItems;
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green.withAlpha(128),
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                emptyMessage,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
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
        statusText = item.daysInStock != null 
            ? '${item.daysInStock} days' 
            : 'No stock history';
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
              color: statusColor.withAlpha(51),
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
              color: statusColor.withAlpha(51),
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

  Future<void> _showDateRangePicker(BuildContext context) async {
    final reportNotifier = ref.read(reportNotifierProvider.notifier);
    final reportState = ref.read(reportNotifierProvider);
    
    final initialDateRange = DateTimeRange(
      start: reportState.startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      end: reportState.endDate ?? DateTime.now(),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: initialDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0F172A),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      reportNotifier.setDateRange(picked.start, picked.end);
      if (mounted) {
        showSuccessSnackTop(
          context,
          'Date range set: ${DateFormat('MMM dd').format(picked.start)} - ${DateFormat('MMM dd').format(picked.end)}',
        );
      }
    }
  }

  Future<void> _handleExport(String format) async {
    final reportState = ref.read(reportNotifierProvider);
    
    List<ReportItem> items;
    String reportType;
    String reportTitle;

    switch (selectedTabIndex) {
      case 0:
        items = reportState.oldStockItems;
        reportType = 'old_stock';
        reportTitle = 'Old Stock Report';
        break;
      case 1:
        items = reportState.outOfStockItems;
        reportType = 'out_of_stock';
        reportTitle = 'Out of Stock Report';
        break;
      case 2:
        items = reportState.lowStockItems;
        reportType = 'low_stock';
        reportTitle = 'Low Stock Report';
        break;
      default:
        items = reportState.allItems;
        reportType = 'all';
        reportTitle = 'Inventory Report';
    }

    if (items.isEmpty) {
      showErrorSnackTop(context, 'No data to export');
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      String filePath;
      
      if (format == 'csv') {
        filePath = await ExportService.exportReportToCSV(
          items: items,
          reportType: reportType,
          startDate: reportState.startDate,
          endDate: reportState.endDate,
        );
      } else {
        filePath = await ExportService.exportReportToPDF(
          items: items,
          reportType: reportType,
          reportTitle: reportTitle,
          startDate: reportState.startDate,
          endDate: reportState.endDate,
        );
      }

      if (mounted) {
        Navigator.pop(context);
        
        _showExportSuccessDialog(filePath, format);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        showErrorSnackTop(context, 'Export failed: ${e.toString()}');
      }
    }
  }

  void _showExportSuccessDialog(String filePath, String format) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              format == 'csv' ? Icons.table_chart : Icons.picture_as_pdf,
              color: format == 'csv' ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            const Text(
              'Export Successful',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'File exported successfully!',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder, color: Colors.grey, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      filePath.split('/').last,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ExportService.shareFile(filePath);
            },
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
