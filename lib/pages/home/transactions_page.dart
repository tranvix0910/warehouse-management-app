import 'package:flutter/material.dart';

enum TransactionType { stockIn, stockOut }

class TransactionModel {
  final TransactionType type;
  final int quantity;
  final int items;
  final String party; // Supplier for Stock In, Customer for Stock Out
  final String date;

  TransactionModel({
    required this.type,
    required this.quantity,
    required this.items,
    required this.party,
    required this.date,
  });
}

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final List<TransactionModel> transactions = [
    TransactionModel(
      type: TransactionType.stockIn,
      quantity: 40,
      items: 2,
      party: 'Acer Corporation',
      date: 'Oct 11, 2024',
    ),
    TransactionModel(
      type: TransactionType.stockOut,
      quantity: -58,
      items: 2,
      party: 'Sarah Williams',
      date: 'Oct 11, 2024',
    ),
    TransactionModel(
      type: TransactionType.stockIn,
      quantity: 181,
      items: 3,
      party: 'HP corporation',
      date: 'Oct 11, 2024',
    ),
    TransactionModel(
      type: TransactionType.stockOut,
      quantity: -40,
      items: 2,
      party: 'John Carter',
      date: 'Oct 11, 2024',
    ),
    TransactionModel(
      type: TransactionType.stockIn,
      quantity: 65,
      items: 2,
      party: 'Acer Corporation',
      date: 'Oct 11, 2024',
    ),
    TransactionModel(
      type: TransactionType.stockIn,
      quantity: 73,
      items: 3,
      party: 'Dell Technologies',
      date: 'Oct 11, 2024',
    ),
  ];

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
      body: ListView.builder(
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
}
