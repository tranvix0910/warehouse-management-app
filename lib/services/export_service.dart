import 'dart:io';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/report_provider.dart';
import '../models/transaction_models.dart';

class ExportService {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd_HH-mm-ss');
  static final DateFormat _displayDateFormat = DateFormat('MMM dd, yyyy HH:mm');

  static Future<String> exportReportToCSV({
    required List<ReportItem> items,
    required String reportType,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final List<List<dynamic>> rows = [];

    rows.add([
      'ID',
      'Product Name',
      'SKU',
      'Category',
      'Stock',
      'Cost',
      'Price',
      'Status',
      'Days In Stock',
    ]);

    for (final item in items) {
      rows.add([
        item.id,
        item.name,
        item.sku,
        item.category,
        item.stock,
        item.cost,
        item.price,
        _getStatusLabel(item.status),
        item.daysInStock ?? 'N/A',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final timestamp = _dateFormat.format(DateTime.now());
    final fileName = '${reportType}_report_$timestamp.csv';

    if (kIsWeb) {
      return csv;
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csv);

    return file.path;
  }

  static Future<String> exportTransactionsToCSV({
    required List<Transaction> transactions,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final List<List<dynamic>> rows = [];

    rows.add([
      'ID',
      'Type',
      'Date',
      'Party',
      'Items Count',
      'Total Quantity',
      'Note',
    ]);

    for (final transaction in transactions) {
      rows.add([
        transaction.id,
        transaction.type == 'stock_in' ? 'Stock In' : 'Stock Out',
        transaction.date,
        transaction.partyName,
        transaction.itemCount,
        transaction.quantity,
        transaction.note ?? '',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final timestamp = _dateFormat.format(DateTime.now());
    final fileName = 'transactions_$timestamp.csv';

    if (kIsWeb) {
      return csv;
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csv);

    return file.path;
  }

  static Future<String> exportReportToPDF({
    required List<ReportItem> items,
    required String reportType,
    required String reportTitle,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildPDFHeader(reportTitle, startDate, endDate),
        footer: (context) => _buildPDFFooter(context),
        build: (context) => [
          pw.SizedBox(height: 20),
          _buildReportSummary(items, reportType),
          pw.SizedBox(height: 20),
          _buildReportTable(items),
        ],
      ),
    );

    final timestamp = _dateFormat.format(DateTime.now());
    final fileName = '${reportType}_report_$timestamp.pdf';

    if (kIsWeb) {
      final bytes = await pdf.save();
      return String.fromCharCodes(bytes);
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  static Future<String> exportTransactionsToPDF({
    required List<Transaction> transactions,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildPDFHeader('Transaction Report', startDate, endDate),
        footer: (context) => _buildPDFFooter(context),
        build: (context) => [
          pw.SizedBox(height: 20),
          _buildTransactionSummary(transactions),
          pw.SizedBox(height: 20),
          _buildTransactionTable(transactions),
        ],
      ),
    );

    final timestamp = _dateFormat.format(DateTime.now());
    final fileName = 'transactions_$timestamp.pdf';

    if (kIsWeb) {
      final bytes = await pdf.save();
      return String.fromCharCodes(bytes);
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  static pw.Widget _buildPDFHeader(String title, DateTime? startDate, DateTime? endDate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Warehouse Management',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue800,
              ),
            ),
            pw.Text(
              _displayDateFormat.format(DateTime.now()),
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (startDate != null || endDate != null) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            'Date Range: ${startDate != null ? DateFormat('MMM dd, yyyy').format(startDate) : 'N/A'} - ${endDate != null ? DateFormat('MMM dd, yyyy').format(endDate) : 'N/A'}',
            style: const pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            ),
          ),
        ],
        pw.Divider(color: PdfColors.blue800, thickness: 2),
      ],
    );
  }

  static pw.Widget _buildPDFFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: const pw.TextStyle(
          fontSize: 10,
          color: PdfColors.grey600,
        ),
      ),
    );
  }

  static pw.Widget _buildReportSummary(List<ReportItem> items, String reportType) {
    final totalItems = items.length;
    final totalStock = items.fold<int>(0, (sum, item) => sum + item.stock);
    final totalValue = items.fold<double>(0, (sum, item) => sum + (double.tryParse(item.price) ?? 0) * item.stock);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Total Items', totalItems.toString()),
          _buildSummaryItem('Total Stock', totalStock.toString()),
          _buildSummaryItem('Total Value', '\$${totalValue.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  static pw.Widget _buildTransactionSummary(List<Transaction> transactions) {
    final stockInCount = transactions.where((t) => t.type == 'stock_in').length;
    final stockOutCount = transactions.where((t) => t.type == 'stock_out').length;
    final totalQuantity = transactions.fold<int>(0, (sum, t) => sum + t.quantity);

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Stock In', stockInCount.toString()),
          _buildSummaryItem('Stock Out', stockOutCount.toString()),
          _buildSummaryItem('Total Qty', totalQuantity.toString()),
        ],
      ),
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 20,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue800,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey600,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildReportTable(List<ReportItem> items) {
    return pw.TableHelper.fromTextArray(
      headers: ['Name', 'SKU', 'Category', 'Stock', 'Price', 'Status'],
      data: items.map((item) => [
        item.name,
        item.sku,
        item.category,
        item.stock.toString(),
        '\$${item.price}',
        _getStatusLabel(item.status),
      ]).toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.blue800,
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(6),
      border: pw.TableBorder.all(color: PdfColors.grey300),
    );
  }

  static pw.Widget _buildTransactionTable(List<Transaction> transactions) {
    return pw.TableHelper.fromTextArray(
      headers: ['Type', 'Date', 'Party', 'Items', 'Qty', 'Note'],
      data: transactions.map((t) => [
        t.type == 'stock_in' ? 'In' : 'Out',
        t.date.length > 10 ? t.date.substring(0, 10) : t.date,
        t.partyName.length > 15 ? '${t.partyName.substring(0, 15)}...' : t.partyName,
        t.itemCount.toString(),
        t.quantity.toString(),
        (t.note ?? '').length > 20 ? '${t.note!.substring(0, 20)}...' : (t.note ?? '-'),
      ]).toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.blue800,
      ),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(6),
      border: pw.TableBorder.all(color: PdfColors.grey300),
    );
  }

  static String _getStatusLabel(String status) {
    switch (status) {
      case 'old':
        return 'Old Stock';
      case 'out':
        return 'Out of Stock';
      case 'low':
        return 'Low Stock';
      default:
        return status;
    }
  }

  static Future<void> shareFile(String filePath) async {
    if (kIsWeb) {
      return;
    }
    await Share.shareXFiles([XFile(filePath)]);
  }
}
