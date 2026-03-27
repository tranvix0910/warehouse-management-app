import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../apis/transaction_api.dart';
import '../models/transaction_models.dart';
import '../models/pagination_models.dart';

class DateRange {
  final DateTime? start;
  final DateTime? end;

  const DateRange({this.start, this.end});

  bool contains(DateTime date) {
    if (start != null && date.isBefore(start!)) return false;
    if (end != null && date.isAfter(end!)) return false;
    return true;
  }
}

class TransactionState {
  final List<Transaction> transactions;
  final List<Transaction> filteredTransactions;
  final bool isLoading;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? typeFilter;
  final DateRange? dateRange;
  final String searchQuery;
  final int currentPage;
  final int total;
  final bool hasMore;

  const TransactionState({
    this.transactions = const [],
    this.filteredTransactions = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.typeFilter,
    this.dateRange,
    this.searchQuery = '',
    this.currentPage = 1,
    this.total = 0,
    this.hasMore = true,
  });

  TransactionState copyWith({
    List<Transaction>? transactions,
    List<Transaction>? filteredTransactions,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    String? typeFilter,
    DateRange? dateRange,
    String? searchQuery,
    int? currentPage,
    int? total,
    bool? hasMore,
  }) {
    return TransactionState(
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      typeFilter: typeFilter ?? this.typeFilter,
      dateRange: dateRange ?? this.dateRange,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class TransactionNotifier extends StateNotifier<TransactionState> {
  TransactionNotifier() : super(const TransactionState());

  static const int _pageSize = 20;

  Future<void> loadTransactions({bool refresh = false}) async {
    if (state.isLoading) return;
    
    state = state.copyWith(
      isLoading: true, 
      errorMessage: null,
      currentPage: refresh ? 1 : state.currentPage,
    );

    try {
      final response = await GetAllTransactionsApi.getAllTransactions(
        params: PaginationParams(
          page: 1,
          limit: _pageSize,
          type: state.typeFilter,
        ),
      );
      final transactionResponse = TransactionResponse.fromJson(response);

      if (transactionResponse.success) {
        final transactions = transactionResponse.data;
        
        PaginationInfo? pagination;
        if (response['pagination'] != null) {
          pagination = PaginationInfo.fromJson(response['pagination']);
        }
        
        state = state.copyWith(
          transactions: transactions,
          filteredTransactions: _applyFilters(
            transactions,
            state.typeFilter,
            state.dateRange,
            state.searchQuery,
          ),
          isLoading: false,
          currentPage: 1,
          total: pagination?.total ?? transactions.length,
          hasMore: pagination?.hasNextPage ?? false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: transactionResponse.message,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final response = await GetAllTransactionsApi.getAllTransactions(
        params: PaginationParams(
          page: nextPage,
          limit: _pageSize,
          type: state.typeFilter,
        ),
      );
      final transactionResponse = TransactionResponse.fromJson(response);

      if (transactionResponse.success) {
        final newTransactions = transactionResponse.data;
        final allTransactions = [...state.transactions, ...newTransactions];
        
        PaginationInfo? pagination;
        if (response['pagination'] != null) {
          pagination = PaginationInfo.fromJson(response['pagination']);
        }
        
        state = state.copyWith(
          transactions: allTransactions,
          filteredTransactions: _applyFilters(
            allTransactions,
            state.typeFilter,
            state.dateRange,
            state.searchQuery,
          ),
          isLoadingMore: false,
          currentPage: nextPage,
          hasMore: pagination?.hasNextPage ?? false,
        );
      } else {
        state = state.copyWith(isLoadingMore: false);
      }
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void filterByType(String? type) {
    state = state.copyWith(typeFilter: type);
    loadTransactions(refresh: true);
  }

  void filterByDateRange(DateRange? range) {
    state = state.copyWith(
      dateRange: range,
      filteredTransactions: _applyFilters(
        state.transactions,
        state.typeFilter,
        range,
        state.searchQuery,
      ),
    );
  }

  void search(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredTransactions: _applyFilters(
        state.transactions,
        state.typeFilter,
        state.dateRange,
        query,
      ),
    );
  }

  void clearFilters() {
    state = state.copyWith(
      typeFilter: null,
      dateRange: null,
      searchQuery: '',
      filteredTransactions: state.transactions,
    );
  }

  List<Transaction> _applyFilters(
    List<Transaction> transactions,
    String? type,
    DateRange? dateRange,
    String query,
  ) {
    var filtered = transactions;

    if (type != null && type.isNotEmpty) {
      filtered = filtered.where((t) => t.type == type).toList();
    }

    if (dateRange != null) {
      filtered = filtered.where((t) {
        try {
          final date = DateTime.parse(t.date);
          return dateRange.contains(date);
        } catch (_) {
          return true;
        }
      }).toList();
    }

    if (query.isNotEmpty) {
      final lowercaseQuery = query.toLowerCase();
      filtered = filtered.where((t) =>
        t.partyName.toLowerCase().contains(lowercaseQuery) ||
        (t.note?.toLowerCase().contains(lowercaseQuery) ?? false)
      ).toList();
    }

    return filtered;
  }

  int get totalStockIn => state.transactions
      .where((t) => t.type == 'stock_in')
      .fold(0, (sum, t) => sum + t.quantity);

  int get totalStockOut => state.transactions
      .where((t) => t.type == 'stock_out')
      .fold(0, (sum, t) => sum + t.quantity);

  List<Transaction> getTransactionsByDateRange(DateTime start, DateTime end) {
    return state.transactions.where((t) {
      try {
        final date = DateTime.parse(t.date);
        return date.isAfter(start.subtract(const Duration(days: 1))) &&
               date.isBefore(end.add(const Duration(days: 1)));
      } catch (_) {
        return false;
      }
    }).toList();
  }
}
