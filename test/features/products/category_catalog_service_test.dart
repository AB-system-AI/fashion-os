import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/category.dart';
import 'package:fashion_pos_enterprise/features/products/domain/repositories/product_repositories.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/category_catalog_service.dart';

class _MockCategoryRepository extends Mock implements CategoryRepository {}

class _MockAuditService extends Mock implements AuditService {}

void main() {
  late _MockCategoryRepository repository;
  late CategoryCatalogService service;
  late AuthUser user;

  setUpAll(() {
    registerFallbackValue(
      Category(
        id: 'c1',
        tenantId: 't1',
        name: 'x',
        version: 1,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
  });

  setUp(() {
    repository = _MockCategoryRepository();
    service = CategoryCatalogService(
      repository: repository,
      auditService: _MockAuditService(),
      permissionEngine: const PermissionEngine(),
    );
    user = const AuthUser(
      userId: 'u1',
      employeeId: 'e1',
      email: 'a@b.com',
      emailVerified: true,
      tenantId: 't1',
      permissions: {'category.manage'},
    );
    when(() => repository.create(any())).thenAnswer((i) async => i.positionalArguments.first as Category);
    when(() => repository.getPage(any())).thenAnswer((_) async => const PaginatedResult(items: [], page: 1, pageSize: 10, totalCount: 0, hasMore: false));
    when(() => repository.listTree(any())).thenAnswer((_) async => []);
  });

  test('create category requires manage permission', () async {
    final denied = user.copyWith(permissions: []);
    final now = DateTime.now().toUtc();
    final draft = Category(
      id: '',
      tenantId: 't1',
      name: 'Outerwear',
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final result = await service.create(user: denied, draft: draft);
    expect(result.isFailure, isTrue);
  });
}
