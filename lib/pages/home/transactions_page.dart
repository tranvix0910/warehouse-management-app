import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../models/transaction_models.dart';
import '../../utils/snack_bar.dart';
import '../../services/export_service.dart';
import '../transactions/stock_in_page.dart';
import '../transactions/stock_out_page.dart';
import '../transactions/transaction_detail_page.dart';

class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      ref.read(transactionNotifierProvider.notifier).loadTransactions(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(transactionNotifierProvider.notifier).loadMore();
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _showNewTransactionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text(
                  'New Transaction',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                _buildTransactionOption(
                  icon: Icons.keyboard_arrow_down,
                  iconColor: const Color(0xFF3B82F6),
                  backgroundColor: const Color(0xFF3B82F6).withOpacity(0.1),
                  title: 'Stock In',
                  onTap: () {
                    Navigator.pop(context);
                    _handleStockIn();
                  },
                ),
                
                const SizedBox(height: 16),
                
                _buildTransactionOption(
                  icon: Icons.keyboard_arrow_up,
                  iconColor: const Color(0xFFFF6B6B),
                  backgroundColor: const Color(0xFFFF6B6B).withOpacity(0.1),
                  title: 'Stock Out',
                  onTap: () {
                    Navigator.pop(context);
                    _handleStockOut();
                  },
                ),
                
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: MediaQuery.of(context).padding.bottom),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTransactionOption({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF334155),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[600],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _handleStockIn() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StockInPage(),
      ),
    ).then((_) {
      ref.read(transactionNotifierProvider.notifier).loadTransactions(refresh: true);
    });
  }

  void _handleStockOut() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StockOutPage(),
      ),
    ).then((_) {
      ref.read(transactionNotifierProvider.notifier).loadTransactions(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = ref.watch(transactionNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text(
          'Transaction History',
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
          if (transactionState.dateRange != null)
            IconButton(
              onPressed: () {
                ref.read(transactionNotifierProvider.notifier).clearFilters();
              },
              icon: const Icon(Icons.clear, color: Colors.orange),
              tooltip: 'Clear filters',
            ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            color: const Color(0xFF1E293B),
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'filter_all',
                child: Row(
                  children: [
                    Icon(
                      Icons.all_inclusive,
                      color: transactionState.typeFilter == null ? Colors.blue : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('All Transactions', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'filter_stock_in',
                child: Row(
                  children: [
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: transactionState.typeFilter == 'stock_in' ? Colors.blue : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Stock In Only', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'filter_stock_out',
                child: Row(
                  children: [
                    Icon(
                      Icons.keyboard_arrow_up,
                      color: transactionState.typeFilter == 'stock_out' ? Colors.blue : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Stock Out Only', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'date_range',
                child: Row(
                  children: [
                    Icon(
                      Icons.date_range,
                      color: transactionState.dateRange != null ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    const Text('Date Range', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'export_csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart, color: Colors.green, size: 20),
                    SizedBox(width: 12),
                    Text('Export to CSV', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'export_pdf',
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
      body: _buildBody(transactionState),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewTransactionModal,
        backgroundColor: const Color(0xFF3B82F6),
        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        label: const Text(
          'New Transaction',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    final transactionNotifier = ref.read(transactionNotifierProvider.notifier);
    
    switch (action) {
      case 'filter_all':
        transactionNotifier.filterByType(null);
        break;
      case 'filter_stock_in':
        transactionNotifier.filterByType('stock_in');
        break;
      case 'filter_stock_out':
        transactionNotifier.filterByType('stock_out');
        break;
      case 'date_range':
        _showDateRangePicker();
        break;
      case 'export_csv':
        _handleExport('csv');
        break;
      case 'export_pdf':
        _handleExport('pdf');
        break;
    }
  }

  Future<void> _showDateRangePicker() async {
    final transactionNotifier = ref.read(transactionNotifierProvider.notifier);
    final transactionState = ref.read(transactionNotifierProvider);
    
    final initialDateRange = DateTimeRange(
      start: transactionState.dateRange?.start ?? DateTime.now().subtract(const Duration(days: 30)),
      end: transactionState.dateRange?.end ?? DateTime.now(),
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
      transactionNotifier.filterByDateRange(DateRange(start: picked.start, end: picked.end));
      if (mounted) {
        showSuccessSnackTop(
          context,
          'Filtered: ${DateFormat('MMM dd').format(picked.start)} - ${DateFormat('MMM dd').format(picked.end)}',
        );
      }
    }
  }

  Future<void> _handleExport(String format) async {
    final transactionState = ref.read(transactionNotifierProvider);
    final transactions = transactionState.filteredTransactions;

    if (transactions.isEmpty) {
      showErrorSnackTop(context, 'No transactions to export');
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      String filePath;
      
      if (format == 'csv') {
        filePath = await ExportService.exportTransactionsToCSV(
          transactions: transactions,
          startDate: transactionState.dateRange?.start,
          endDate: transactionState.dateRange?.end,
        );
      } else {
        filePath = await ExportService.exportTransactionsToPDF(
          transactions: transactions,
          startDate: transactionState.dateRange?.start,
          endDate: transactionState.dateRange?.end,
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
            const Text('Export Successful', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('File exported successfully!', style: TextStyle(color: Colors.white70)),
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
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
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

  Widget _buildBody(TransactionState transactionState) {
    if (transactionState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
        ),
      );
    }

    if (transactionState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load transactions',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              transactionState.errorMessage!,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(transactionNotifierProvider.notifier).loadTransactions(refresh: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final transactions = transactionState.filteredTransactions;

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              transactionState.dateRange != null || transactionState.typeFilter != null
                  ? 'No transactions match filters'
                  : 'No transactions found',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              transactionState.dateRange != null || transactionState.typeFilter != null
                  ? 'Try adjusting your filters'
                  : 'Start by creating your first transaction',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            if (transactionState.dateRange != null || transactionState.typeFilter != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => ref.read(transactionNotifierProvider.notifier).clearFilters(),
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        if (transactionState.dateRange != null || transactionState.typeFilter != null)
          _buildFilterIndicator(transactionState),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${transactions.length} of ${transactionState.total} transactions',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              if (transactionState.hasMore)
                const Text(
                  'Scroll for more',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => ref.read(transactionNotifierProvider.notifier).loadTransactions(refresh: true),
            backgroundColor: const Color(0xFF1E293B),
            color: const Color(0xFF3B82F6),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length + (transactionState.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= transactions.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                final transaction = transactions[index];
                return _buildTransactionItem(transaction);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterIndicator(TransactionState transactionState) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6).withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.filter_list, color: Color(0xFF3B82F6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (transactionState.typeFilter != null)
                  _buildFilterChip(
                    transactionState.typeFilter == 'stock_in' ? 'Stock In' : 'Stock Out',
                    Icons.swap_vert,
                  ),
                if (transactionState.dateRange != null)
                  _buildFilterChip(
                    '${dateFormat.format(transactionState.dateRange!.start!)} - ${dateFormat.format(transactionState.dateRange!.end!)}',
                    Icons.date_range,
                  ),
              ],
            ),
          ),
          Text(
            '${transactionState.filteredTransactions.length} results',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isStockIn = transaction.isStockIn;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailPage(
              transaction: transaction,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF334155),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isStockIn 
                      ? const Color(0xFF3B82F6).withOpacity(0.2)
                      : const Color(0xFFFF6B6B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isStockIn 
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                    color: isStockIn 
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFFFF6B6B),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${isStockIn ? '+' : '-'}${transaction.quantity}',
                  style: TextStyle(
                    color: isStockIn 
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFFFF6B6B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isStockIn ? 'Stock In' : 'Stock Out',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Items: ${transaction.itemCount}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isStockIn 
                      ? 'Supplier: ${transaction.partyName}'
                      : 'Customer: ${transaction.partyName}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  if (transaction.note != null && transaction.note!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Note: ${transaction.note}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              _formatDate(transaction.date),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
