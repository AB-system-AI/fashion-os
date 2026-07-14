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
  bool get isFirstPage => page <= 1;
  bool get isLastPage => !hasMore;
}

/// Query parameters for paginated repository calls.
class PaginationQuery {
  const PaginationQuery({
    this.page = 1,
    this.pageSize = 50,
    this.sortBy,
    this.sortDescending = true,
    this.search,
    this.filters = const {},
  });

  final int page;
  final int pageSize;
  final String? sortBy;
  final bool sortDescending;
  final String? search;
  final Map<String, String> filters;

  int get offset => (page - 1) * pageSize;

  PaginationQuery nextPage() => PaginationQuery(
        page: page + 1,
        pageSize: pageSize,
        sortBy: sortBy,
        sortDescending: sortDescending,
        search: search,
        filters: filters,
      );
}

/// Offset/limit SQL builder for local and remote queries.
class PaginationSql {
  static String orderClause(PaginationQuery query, {String defaultSort = 'updated_at'}) {
    final column = query.sortBy ?? defaultSort;
    final direction = query.sortDescending ? 'DESC' : 'ASC';
    return 'ORDER BY $column $direction';
  }

  static String limitClause(PaginationQuery query) {
    return 'LIMIT ${query.pageSize} OFFSET ${query.offset}';
  }
}
