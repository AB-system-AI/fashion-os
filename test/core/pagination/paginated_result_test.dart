import 'package:fashion_pos_enterprise/core/pagination/paginated_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaginationQuery', () {
    test('offset calculates from page and pageSize', () {
      const query = PaginationQuery(page: 3, pageSize: 25);
      expect(query.offset, 50);
    });

    test('nextPage increments page', () {
      const query = PaginationQuery(page: 2, pageSize: 10);
      expect(query.nextPage().page, 3);
    });
  });

  group('PaginatedResult', () {
    test('totalPages rounds up', () {
      const result = PaginatedResult<String>(
        items: ['a'],
        page: 1,
        pageSize: 50,
        totalCount: 120,
        hasMore: true,
      );
      expect(result.totalPages, 3);
      expect(result.isLastPage, false);
    });

    test('isLastPage when hasMore is false', () {
      const result = PaginatedResult<int>(
        items: [],
        page: 2,
        pageSize: 50,
        totalCount: 100,
      );
      expect(result.isLastPage, true);
    });
  });

  group('PaginationSql', () {
    test('builds order and limit clauses', () {
      const query = PaginationQuery(page: 2, pageSize: 20, sortBy: 'name');
      expect(PaginationSql.orderClause(query), 'ORDER BY name DESC');
      expect(PaginationSql.limitClause(query), 'LIMIT 20 OFFSET 20');
    });
  });
}
