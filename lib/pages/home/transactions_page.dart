import 'package:flutter/material.dart';
import '../../apis/transaction_api.dart';

enum TransactionType { stockIn, stockOut }

class TransactionModel {
  final TransactionType type;
  final int quantity;
  final int items;
  final String party; // Supplier for Stock In, Customer for Stock Out
  final String date;
  final String? note;

  TransactionModel({
    required this.type,
    required this.quantity,
    required this.items,
    required this.party,
    required this.date,
    this.note,
  });
}

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final List<TransactionModel> transactions = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await TransactionApi.getTransactions();
      final parsed = data.map((t) {
        final String typeStr = (t['type'] ?? '').toString();
        final TransactionType type = typeStr == 'stock_out'
            ? TransactionType.stockOut
            : TransactionType.stockIn;
        final int quantity = (t['quantity'] ?? 0) is int
            ? (t['quantity'] ?? 0) as int
            : int.tryParse((t['quantity'] ?? '0').toString()) ?? 0;
        final int itemsCount = (t['items'] is List)
            ? (t['items'] as List).length
            : 0;
        final String party = type == TransactionType.stockIn
            ? (t['supplier'] ?? '-')
            : (t['customer'] ?? '-');
        final String date = _formatDate(t['date']);
        final String? note =
            (t['note'] == null || (t['note'].toString()).trim().isEmpty)
            ? null
            : t['note'].toString();
        return TransactionModel(
          type: type,
          quantity: type == TransactionType.stockIn ? quantity : -quantity,
          items: itemsCount,
          party: party,
          date: date,
          note: note,
        );
      }).toList();

      setState(() {
        transactions
          ..clear()
          ..addAll(parsed.cast<TransactionModel>());
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _formatDate(dynamic value) {
    try {
      if (value == null) return '';
      final dt = DateTime.tryParse(value.toString());
      if (dt == null) return value.toString();
      // Simple format: Mon DD, YYYY
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return value.toString();
    }
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
            icon: const Icon(Icons.menu, color: Colors.white),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final isStockIn = transaction.type == TransactionType.stockIn;

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
                            '${transaction.quantity > 0 ? '+' : ''}${transaction.quantity}',
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
                              'Items: ${transaction.items}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isStockIn
                                  ? 'Supplier: ${transaction.party}'
                                  : 'Customer: ${transaction.party}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            if (transaction.note != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Note: ${transaction.note}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Date
                      Text(
                        transaction.date,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Add new transaction
        },
        backgroundColor: const Color(0xFF3B82F6),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Transaction',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
