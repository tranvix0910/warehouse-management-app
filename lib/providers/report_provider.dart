import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../apis/summary_report_api.dart';
import '../apis/old_stock_api.dart';
import '../apis/out_stock_api.dart';
import '../apis/low_stack_api.dart';

class ReportItem {
  final String id;
  final String name;
  final String sku;
  final int stock;
  final int? daysInStock;
  final String status;
  final String? image;
  final String category;
  final String cost;
  final String price;

  ReportItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.stock,
    this.daysInStock,
    required this.status,
    this.image,
    required this.category,
    required this.cost,
    required this.price,
  });

  factory ReportItem.fromApi(Map<String, dynamic> data, String status) {
    return ReportItem(
      id: data['_id']?.toString() ?? '',
      name: data['productName']?.toString() ?? '',
      sku: data['SKU']?.toString() ?? '',
      stock: (data['quantity'] as int?) ?? 0,
      daysInStock: data['daysSinceLastStockIn'] as int?,
      status: status,
      image: data['image']?.toString(),
      category: data['category']?.toString() ?? '',
      cost: data['cost']?.toString() ?? '0',
      price: data['price']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'stock': stock,
      'daysInStock': daysInStock,
      'status': status,
      'category': category,
      'cost': cost,
      'price': price,
    };
  }
}

class ReportSummary {
  final int lowStockCount;
  final int oldStockCount;
  final int outOfStockCount;
  final int totalProductCount;

  const ReportSummary({
    this.lowStockCount = 0,
    this.oldStockCount = 0,
    this.outOfStockCount = 0,
    this.totalProductCount = 0,
  });
}

class ReportState {
  final ReportSummary summary;
  final List<ReportItem> oldStockItems;
  final List<ReportItem> outOfStockItems;
  final List<ReportItem> lowStockItems;
  final bool isLoading;
  final String? errorMessage;
  final DateTime? startDate;
  final DateTime? endDate;

  const ReportState({
    this.summary = const ReportSummary(),
    this.oldStockItems = const [],
    this.outOfStockItems = const [],
    this.lowStockItems = const [],
    this.isLoading = false,
    this.errorMessage,
    this.startDate,
    this.endDate,
  });

  ReportState copyWith({
    ReportSummary? summary,
    List<ReportItem>? oldStockItems,
    List<ReportItem>? outOfStockItems,
    List<ReportItem>? lowStockItems,
    bool? isLoading,
    String? errorMessage,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ReportState(
      summary: summary ?? this.summary,
      oldStockItems: oldStockItems ?? this.oldStockItems,
      outOfStockItems: outOfStockItems ?? this.outOfStockItems,
      lowStockItems: lowStockItems ?? this.lowStockItems,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  List<ReportItem> get allItems => [
    ...oldStockItems,
    ...outOfStockItems,
    ...lowStockItems,
  ];
}

class ReportNotifier extends StateNotifier<ReportState> {
  ReportNotifier() : super(const ReportState());

  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final summaryResponse = await SummaryReportApi.getSummaryReport();
      final summaryData = summaryResponse['data'] as Map<String, dynamic>;

      final oldStockResponse = await SummaryOldStockApi.getOldStockReport();
      final outStockResponse = await SummaryOutStockApi.getOutOfStockReport();
      final lowStockResponse = await LowStockApi.getLowStockReport();

      final List<dynamic> oldStockData = oldStockResponse['data'] as List<dynamic>;
      final List<dynamic> outStockData = outStockResponse['data'] as List<dynamic>;
      final List<dynamic> lowStockData = lowStockResponse['data'] as List<dynamic>;

      state = state.copyWith(
        summary: ReportSummary(
          lowStockCount: summaryData['lowStock'] as int? ?? 0,
          oldStockCount: summaryData['oldStock'] as int? ?? 0,
          outOfStockCount: summaryData['outOfStock'] as int? ?? 0,
          totalProductCount: summaryData['totalProduct'] as int? ?? 0,
        ),
        oldStockItems: oldStockData
            .map((item) => ReportItem.fromApi(item as Map<String, dynamic>, 'old'))
            .toList(),
        outOfStockItems: outStockData
            .map((item) => ReportItem.fromApi(item as Map<String, dynamic>, 'out'))
            .toList(),
        lowStockItems: lowStockData
            .map((item) => ReportItem.fromApi(item as Map<String, dynamic>, 'low'))
            .toList(),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(
      startDate: start,
      endDate: end,
    );
  }

  void clearDateRange() {
    state = state.copyWith(
      startDate: null,
      endDate: null,
    );
  }
}
