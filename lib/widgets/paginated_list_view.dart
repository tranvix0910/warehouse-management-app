import 'package:flutter/material.dart';
import '../models/pagination_models.dart';

typedef PaginatedFetcher<T> = Future<PaginatedResponse<T>> Function(PaginationParams params);
typedef ItemBuilder<T> = Widget Function(BuildContext context, T item, int index);

class PaginatedListView<T> extends StatefulWidget {
  final PaginatedFetcher<T> fetcher;
  final ItemBuilder<T> itemBuilder;
  final Widget? emptyWidget;
  final Widget? errorWidget;
  final Widget? loadingWidget;
  final Widget? loadingMoreWidget;
  final int initialLimit;
  final String? searchQuery;
  final String? filterType;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final double loadMoreThreshold;
  final Widget? header;
  final Widget? separator;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final RefreshCallback? onRefresh;
  final VoidCallback? onLoadMore;

  const PaginatedListView({
    super.key,
    required this.fetcher,
    required this.itemBuilder,
    this.emptyWidget,
    this.errorWidget,
    this.loadingWidget,
    this.loadingMoreWidget,
    this.initialLimit = 20,
    this.searchQuery,
    this.filterType,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.loadMoreThreshold = 200.0,
    this.header,
    this.separator,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.onRefresh,
    this.onLoadMore,
  });

  @override
  State<PaginatedListView<T>> createState() => PaginatedListViewState<T>();
}

class PaginatedListViewState<T> extends State<PaginatedListView<T>> {
  final List<T> _items = [];
  PaginationInfo? _pagination;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String _errorMessage = '';
  late ScrollController _scrollController;
  late PaginationParams _currentParams;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(_onScroll);
    _currentParams = PaginationParams(
      page: 1,
      limit: widget.initialLimit,
      search: widget.searchQuery,
      type: widget.filterType,
    );
    _loadInitial();
  }

  @override
  void didUpdateWidget(PaginatedListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.filterType != widget.filterType) {
      _currentParams = PaginationParams(
        page: 1,
        limit: widget.initialLimit,
        search: widget.searchQuery,
        type: widget.filterType,
      );
      refresh();
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - widget.loadMoreThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final response = await widget.fetcher(_currentParams);
      if (mounted) {
        setState(() {
          _items.clear();
          _items.addAll(response.data);
          _pagination = response.pagination;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _isLoading || !(_pagination?.hasNextPage ?? false)) {
      return;
    }

    setState(() => _isLoadingMore = true);

    try {
      _currentParams = _currentParams.nextPage();
      final response = await widget.fetcher(_currentParams);
      if (mounted) {
        setState(() {
          _items.addAll(response.data);
          _pagination = response.pagination;
          _isLoadingMore = false;
        });
        widget.onLoadMore?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _currentParams = _currentParams.copyWith(page: (_currentParams.page ?? 1) - 1);
        });
      }
    }
  }

  Future<void> refresh() async {
    _currentParams = _currentParams.reset();
    await _loadInitial();
    widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _items.isEmpty) {
      return widget.loadingWidget ?? _buildDefaultLoading();
    }

    if (_hasError && _items.isEmpty) {
      return widget.errorWidget ?? _buildDefaultError();
    }

    if (_items.isEmpty) {
      return widget.emptyWidget ?? _buildDefaultEmpty();
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: _buildListView(),
    );
  }

  Widget _buildListView() {
    final itemCount = _items.length + (_isLoadingMore ? 1 : 0) + (widget.header != null ? 1 : 0);

    return ListView.separated(
      controller: _scrollController,
      physics: widget.physics ?? const AlwaysScrollableScrollPhysics(),
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      itemCount: itemCount,
      separatorBuilder: (context, index) {
        if (widget.header != null && index == 0) {
          return const SizedBox.shrink();
        }
        return widget.separator ?? const SizedBox(height: 8);
      },
      itemBuilder: (context, index) {
        if (widget.header != null && index == 0) {
          return widget.header!;
        }

        final itemIndex = widget.header != null ? index - 1 : index;

        if (itemIndex >= _items.length) {
          return widget.loadingMoreWidget ?? _buildDefaultLoadingMore();
        }

        return widget.itemBuilder(context, _items[itemIndex], itemIndex);
      },
    );
  }

  Widget _buildDefaultLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildDefaultLoadingMore() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No items found',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<T> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  int get total => _pagination?.total ?? _items.length;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _pagination?.hasNextPage ?? false;
}

class PaginatedGridView<T> extends StatefulWidget {
  final PaginatedFetcher<T> fetcher;
  final ItemBuilder<T> itemBuilder;
  final SliverGridDelegate gridDelegate;
  final Widget? emptyWidget;
  final Widget? loadingWidget;
  final int initialLimit;
  final String? searchQuery;
  final String? filterType;
  final EdgeInsetsGeometry? padding;
  final double loadMoreThreshold;

  const PaginatedGridView({
    super.key,
    required this.fetcher,
    required this.itemBuilder,
    required this.gridDelegate,
    this.emptyWidget,
    this.loadingWidget,
    this.initialLimit = 20,
    this.searchQuery,
    this.filterType,
    this.padding,
    this.loadMoreThreshold = 200.0,
  });

  @override
  State<PaginatedGridView<T>> createState() => PaginatedGridViewState<T>();
}

class PaginatedGridViewState<T> extends State<PaginatedGridView<T>> {
  final List<T> _items = [];
  PaginationInfo? _pagination;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  late ScrollController _scrollController;
  late PaginationParams _currentParams;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _currentParams = PaginationParams(
      page: 1,
      limit: widget.initialLimit,
      search: widget.searchQuery,
      type: widget.filterType,
    );
    _loadInitial();
  }

  @override
  void didUpdateWidget(PaginatedGridView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery ||
        oldWidget.filterType != widget.filterType) {
      _currentParams = PaginationParams(
        page: 1,
        limit: widget.initialLimit,
        search: widget.searchQuery,
        type: widget.filterType,
      );
      refresh();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - widget.loadMoreThreshold) {
      _loadMore();
    }
  }

  Future<void> _loadInitial() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await widget.fetcher(_currentParams);
      if (mounted) {
        setState(() {
          _items.clear();
          _items.addAll(response.data);
          _pagination = response.pagination;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _isLoading || !(_pagination?.hasNextPage ?? false)) {
      return;
    }

    setState(() => _isLoadingMore = true);

    try {
      _currentParams = _currentParams.nextPage();
      final response = await widget.fetcher(_currentParams);
      if (mounted) {
        setState(() {
          _items.addAll(response.data);
          _pagination = response.pagination;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _currentParams = _currentParams.copyWith(page: (_currentParams.page ?? 1) - 1);
        });
      }
    }
  }

  Future<void> refresh() async {
    _currentParams = _currentParams.reset();
    await _loadInitial();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _items.isEmpty) {
      return widget.loadingWidget ?? const Center(child: CircularProgressIndicator());
    }

    if (_hasError && _items.isEmpty) {
      return Center(
        child: ElevatedButton.icon(
          onPressed: refresh,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      );
    }

    if (_items.isEmpty) {
      return widget.emptyWidget ?? const Center(child: Text('No items found'));
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverPadding(
            padding: widget.padding ?? EdgeInsets.zero,
            sliver: SliverGrid(
              gridDelegate: widget.gridDelegate,
              delegate: SliverChildBuilderDelegate(
                (context, index) => widget.itemBuilder(context, _items[index], index),
                childCount: _items.length,
              ),
            ),
          ),
          if (_isLoadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  List<T> get items => List.unmodifiable(_items);
  int get total => _pagination?.total ?? _items.length;
  bool get hasMore => _pagination?.hasNextPage ?? false;
}

class LoadMoreIndicator extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;

  const LoadMoreIndicator({
    super.key,
    this.isLoading = false,
    this.hasMore = true,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No more items',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    if (isLoading) {
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

    return GestureDetector(
      onTap: onLoadMore,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Load more',
            style: TextStyle(
              color: Color(0xFF3B82F6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
