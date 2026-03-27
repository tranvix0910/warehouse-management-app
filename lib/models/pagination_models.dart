class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPages: json['totalPages'] ?? 1,
    );
  }

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
  int get nextPage => hasNextPage ? page + 1 : page;
  int get previousPage => hasPreviousPage ? page - 1 : page;
}

class PaginatedResponse<T> {
  final bool success;
  final String message;
  final List<T> data;
  final PaginationInfo? pagination;

  PaginatedResponse({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
  });

  bool get hasPagination => pagination != null;
  bool get hasMore => pagination?.hasNextPage ?? false;
  int get total => pagination?.total ?? data.length;
}

class PaginationParams {
  final int? page;
  final int? limit;
  final String? search;
  final String? type;
  final Map<String, dynamic>? extraParams;

  PaginationParams({
    this.page,
    this.limit,
    this.search,
    this.type,
    this.extraParams,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (page != null) params['page'] = page;
    if (limit != null) params['limit'] = limit;
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (type != null && type!.isNotEmpty) params['type'] = type;
    if (extraParams != null) params.addAll(extraParams!);
    return params;
  }

  PaginationParams copyWith({
    int? page,
    int? limit,
    String? search,
    String? type,
    Map<String, dynamic>? extraParams,
  }) {
    return PaginationParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
      type: type ?? this.type,
      extraParams: extraParams ?? this.extraParams,
    );
  }

  static PaginationParams initial({int limit = 20}) {
    return PaginationParams(page: 1, limit: limit);
  }

  PaginationParams nextPage() {
    return copyWith(page: (page ?? 1) + 1);
  }

  PaginationParams reset() {
    return copyWith(page: 1);
  }
}
