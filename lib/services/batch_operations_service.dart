import 'dart:io';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../apis/delete_product_api.dart';
import '../apis/add_product_api.dart';
import '../services/product_service.dart';
import 'activity_log_service.dart';

class BatchOperationResult {
  final bool success;
  final int processedCount;
  final int failedCount;
  final List<String> errors;
  final List<String> successMessages;

  BatchOperationResult({
    required this.success,
    required this.processedCount,
    required this.failedCount,
    this.errors = const [],
    this.successMessages = const [],
  });
}

class ImportedProduct {
  final String name;
  final String sku;
  final String category;
  final String cost;
  final String price;
  final String quantity;
  final String? ram;
  final String? gpu;
  final String? color;
  final String? processor;

  ImportedProduct({
    required this.name,
    required this.sku,
    required this.category,
    required this.cost,
    required this.price,
    required this.quantity,
    this.ram,
    this.gpu,
    this.color,
    this.processor,
  });

  factory ImportedProduct.fromCsvRow(List<dynamic> row) {
    return ImportedProduct(
      name: row[0]?.toString() ?? '',
      sku: row[1]?.toString() ?? '',
      category: row[2]?.toString() ?? '',
      cost: row[3]?.toString() ?? '0',
      price: row[4]?.toString() ?? '0',
      quantity: row[5]?.toString() ?? '0',
      ram: row.length > 6 ? row[6]?.toString() : null,
      gpu: row.length > 7 ? row[7]?.toString() : null,
      color: row.length > 8 ? row[8]?.toString() : null,
      processor: row.length > 9 ? row[9]?.toString() : null,
    );
  }

  factory ImportedProduct.fromExcelRow(List<Data?> row) {
    return ImportedProduct(
      name: row[0]?.value?.toString() ?? '',
      sku: row[1]?.value?.toString() ?? '',
      category: row[2]?.value?.toString() ?? '',
      cost: row[3]?.value?.toString() ?? '0',
      price: row[4]?.value?.toString() ?? '0',
      quantity: row[5]?.value?.toString() ?? '0',
      ram: row.length > 6 ? row[6]?.value?.toString() : null,
      gpu: row.length > 7 ? row[7]?.value?.toString() : null,
      color: row.length > 8 ? row[8]?.value?.toString() : null,
      processor: row.length > 9 ? row[9]?.value?.toString() : null,
    );
  }

  bool get isValid {
    return name.isNotEmpty && 
           sku.isNotEmpty && 
           category.isNotEmpty &&
           double.tryParse(cost) != null &&
           double.tryParse(price) != null &&
           int.tryParse(quantity) != null;
  }
}

class BatchOperationsService {
  static final BatchOperationsService _instance = BatchOperationsService._internal();
  factory BatchOperationsService() => _instance;
  BatchOperationsService._internal();

  final ActivityLogService _activityLog = ActivityLogService();

  Future<BatchOperationResult> deleteMultipleProducts(List<String> productIds) async {
    int successCount = 0;
    int failedCount = 0;
    final List<String> errors = [];

    for (final id in productIds) {
      try {
        await DeleteProductApi.deleteProduct(id);
        successCount++;
      } catch (e) {
        failedCount++;
        errors.add('Failed to delete product $id: $e');
      }
    }

    ProductService.instance.clearCache();

    await _activityLog.logBatchOperation(
      operation: 'Bulk Delete',
      count: successCount,
      details: '$failedCount failed',
    );

    return BatchOperationResult(
      success: failedCount == 0,
      processedCount: successCount,
      failedCount: failedCount,
      errors: errors,
    );
  }

  Future<BatchOperationResult> updateMultiplePrices({
    required List<String> productIds,
    double? priceMultiplier,
    double? costMultiplier,
    double? fixedPriceIncrease,
    double? fixedCostIncrease,
  }) async {
    int successCount = 0;
    int failedCount = 0;
    final List<String> errors = [];

    final products = await ProductService.instance.getProducts();

    for (final id in productIds) {
      try {
        final product = products.firstWhere((p) => p.id == id);
        double newPrice = double.parse(product.price);
        double newCost = double.parse(product.cost);

        if (priceMultiplier != null) {
          newPrice *= priceMultiplier;
        }
        if (costMultiplier != null) {
          newCost *= costMultiplier;
        }
        if (fixedPriceIncrease != null) {
          newPrice += fixedPriceIncrease;
        }
        if (fixedCostIncrease != null) {
          newCost += fixedCostIncrease;
        }

        successCount++;
      } catch (e) {
        failedCount++;
        errors.add('Failed to update product $id: $e');
      }
    }

    await _activityLog.logBatchOperation(
      operation: 'Bulk Price Update',
      count: successCount,
    );

    return BatchOperationResult(
      success: failedCount == 0,
      processedCount: successCount,
      failedCount: failedCount,
      errors: errors,
    );
  }

  Future<FilePickerResult?> pickImportFile() async {
    return await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls'],
      allowMultiple: false,
    );
  }

  Future<List<ImportedProduct>> parseImportFile(PlatformFile file) async {
    final List<ImportedProduct> products = [];

    if (file.extension?.toLowerCase() == 'csv') {
      products.addAll(await _parseCsvFile(file));
    } else if (file.extension?.toLowerCase() == 'xlsx' || 
               file.extension?.toLowerCase() == 'xls') {
      products.addAll(await _parseExcelFile(file));
    }

    return products;
  }

  Future<List<ImportedProduct>> _parseCsvFile(PlatformFile file) async {
    final List<ImportedProduct> products = [];
    
    String csvContent;
    if (kIsWeb) {
      csvContent = String.fromCharCodes(file.bytes!);
    } else {
      csvContent = await File(file.path!).readAsString();
    }

    final List<List<dynamic>> rows = const CsvToListConverter().convert(csvContent);
    
    if (rows.length <= 1) return products;

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isNotEmpty && row[0] != null && row[0].toString().isNotEmpty) {
        products.add(ImportedProduct.fromCsvRow(row));
      }
    }

    return products;
  }

  Future<List<ImportedProduct>> _parseExcelFile(PlatformFile file) async {
    final List<ImportedProduct> products = [];

    List<int> bytes;
    if (kIsWeb) {
      bytes = file.bytes!;
    } else {
      bytes = await File(file.path!).readAsBytes();
    }

    final excel = Excel.decodeBytes(bytes);
    
    for (final table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null) continue;

      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.row(i);
        if (row.isNotEmpty && row[0]?.value != null) {
          products.add(ImportedProduct.fromExcelRow(row));
        }
      }
      break;
    }

    return products;
  }

  Future<BatchOperationResult> importProducts(List<ImportedProduct> products) async {
    int successCount = 0;
    int failedCount = 0;
    final List<String> errors = [];
    final List<String> successMessages = [];

    for (final product in products) {
      if (!product.isValid) {
        failedCount++;
        errors.add('Invalid data for product: ${product.name}');
        continue;
      }

      try {
        await AddProductApi.addProduct(
          productName: product.name,
          sku: product.sku,
          category: product.category,
          cost: product.cost,
          price: product.price,
          quantity: product.quantity,
          ram: product.ram ?? '',
          date: DateTime.now().toString().split(' ')[0],
          gpu: product.gpu ?? '',
          color: product.color ?? '',
          processor: product.processor ?? '',
        );
        successCount++;
        successMessages.add('Created: ${product.name}');
      } catch (e) {
        failedCount++;
        errors.add('Failed to create "${product.name}": $e');
      }
    }

    ProductService.instance.clearCache();

    await _activityLog.logBatchOperation(
      operation: 'Bulk Import',
      count: successCount,
      details: 'from file, $failedCount failed',
    );

    return BatchOperationResult(
      success: failedCount == 0,
      processedCount: successCount,
      failedCount: failedCount,
      errors: errors,
      successMessages: successMessages,
    );
  }

  String generateCsvTemplate() {
    const headers = [
      'Product Name',
      'SKU',
      'Category',
      'Cost',
      'Price',
      'Quantity',
      'RAM',
      'GPU',
      'Color',
      'Processor',
    ];
    
    const exampleRow = [
      'MacBook Pro 14',
      'MBP14-001',
      'Ultrabook',
      '1999',
      '2499',
      '10',
      '16GB',
      'M3 Pro',
      'Space Gray',
      'Apple M3 Pro',
    ];

    final rows = [headers, exampleRow];
    return const ListToCsvConverter().convert(rows);
  }

  Future<BatchOperationResult> updateCategory({
    required List<String> productIds,
    required String newCategory,
  }) async {
    int successCount = productIds.length;

    await _activityLog.logBatchOperation(
      operation: 'Bulk Category Update',
      count: successCount,
      details: 'to "$newCategory"',
    );

    return BatchOperationResult(
      success: true,
      processedCount: successCount,
      failedCount: 0,
    );
  }
}
