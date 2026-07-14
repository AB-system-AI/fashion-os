import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/purchasing/purchase_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/repositories/purchasing_repositories.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/services/supplier_service.dart';

class _MockSupplierRepository extends Mock implements SupplierRepository {}

class _MockPurchaseOrderRepository extends Mock implements PurchaseOrderRepository {}

class _MockAuditService extends Mock implements AuditService {}

class _MockNumberGenerator extends Mock implements NumberGeneratorEngine {}

void main() {
  late SupplierService service;
  late _MockSupplierRepository repository;
  late _MockAuditService audit;

  const user = AuthUser(
    userId: 'u1',
    employeeId: 'e1',
    email: 'a@b.com',
    emailVerified: true,
    tenantId: 't1',
    permissions: {'supplier.create'},
  );

  setUpAll(() {
    registerFallbackValue(
      Supplier(
        id: 's1',
        tenantId: 't1',
        supplierCode: 'SUP-1',
        companyName: 'Test',
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
  });

  setUp(() {
    repository = _MockSupplierRepository();
    audit = _MockAuditService();
    service = SupplierService(
      repository: repository,
      purchaseOrderRepository: _MockPurchaseOrderRepository(),
      auditService: audit,
      permissionEngine: PermissionEngine(),
      numberGenerator: _MockNumberGenerator(),
    );
    when(() => repository.findByCode(any(), any())).thenAnswer((_) async => null);
    when(() => repository.create(any())).thenAnswer((inv) async => inv.positionalArguments[0] as Supplier);
    when(() => audit.log(
          action: any(named: 'action'),
          entityType: any(named: 'entityType'),
          tenantId: any(named: 'tenantId'),
          employeeId: any(named: 'employeeId'),
          entityId: any(named: 'entityId'),
          oldValue: any(named: 'oldValue'),
          newValue: any(named: 'newValue'),
          metadata: any(named: 'metadata'),
        )).thenAnswer((_) async {});
  });

  test('create denies without permission', () async {
    const denied = AuthUser(
      userId: 'u1',
      employeeId: 'e1',
      email: 'a@b.com',
      emailVerified: true,
      tenantId: 't1',
      permissions: {},
    );
    final now = DateTime.now().toUtc();
    final result = await service.create(
      user: denied,
      draft: Supplier(
        id: '',
        tenantId: 't1',
        supplierCode: 'SUP-1',
        companyName: 'Test',
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    expect(result.isFailure, isTrue);
    expect(result.failureOrNull?.code, 'permission_denied');
  });
}
