import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../apis/transaction_api.dart';
import '../../models/transaction_models.dart';
import '../../utils/snack_bar.dart';
import '../transactions/stock_in_page.dart';
import '../transactions/stock_out_page.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<Transaction> transactions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await GetAllTransactionsApi.getAllTransactions();
      final transactionResponse = TransactionResponse.fromJson(response);

      if (transactionResponse.success) {
        setState(() {
          transactions = transactionResponse.data;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = transactionResponse.message;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      if (mounted) {
        showErrorSnackTop(context, 'Failed to load transactions: ${e.toString()}');
      }
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
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Title
                const Text(
                  'New Transaction',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Stock In Option
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
                
                // Stock Out Option
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
                
                // Cancel Button
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
                
                // Bottom padding for safe area
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
      // Refresh transactions when returning from Stock In page
      _loadTransactions();
    });
  }

  void _handleStockOut() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const StockOutPage(),
      ),
    ).then((_) {
      // Refresh transactions when returning from Stock Out page
      _loadTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
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
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            color: const Color(0xFF1E293B),
            onSelected: (value) {
              // Handle menu selection
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'filter',
                child: Text(
                  'Filter Transactions',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'export',
                child: Text(
                  'Export to CSV',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'date_range',
                child: Text(
                  'Date Range',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'settings',
                child: Text(
                  'Transaction Settings',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
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

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
        ),
      );
    }

    if (errorMessage != null) {
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
              errorMessage!,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadTransactions,
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
              'No transactions found',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by creating your first transaction',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      backgroundColor: const Color(0xFF1E293B),
      color: const Color(0xFF3B82F6),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          final isStockIn = transaction.isStockIn;
          
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
                // Transaction Type Icon and Quantity
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
                // Transaction Details
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
                // Date
                Text(
                  _formatDate(transaction.date),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
