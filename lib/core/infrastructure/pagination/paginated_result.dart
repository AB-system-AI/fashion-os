/// Paginated data result for large datasets.
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.totalCount,
    this.hasMore = false,
  });

  final List<T> items;
  final int page;
  final int pageSize;
  final int totalCount;
  final bool hasMore;

  int get totalPages => pageSize == 0 ? 0 : (totalCount / pageSize).ceil();
  bool get isEmpty => items.isEmpty;
}
