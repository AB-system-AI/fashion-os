import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/engines/barcode_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/repositories/customer_repositories.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/services/customer_service.dart';

class _MockCustomerRepository extends Mock implements CustomerRepository {}

class _MockAuditService extends Mock implements AuditService {}

class _MockNumberGenerator extends Mock implements NumberGeneratorEngine {}

class _MockBarcodeEngine extends Mock implements BarcodeEngine {}

void main() {
  late CustomerService service;
  late _MockCustomerRepository repository;
  late _MockAuditService audit;

  const user = AuthUser(
    userId: 'u1',
    employeeId: 'e1',
    email: 'a@b.com',
    emailVerified: true,
    tenantId: 't1',
    permissions: {'customer.create'},
  );

  setUpAll(() {
    registerFallbackValue(
      Customer(
        id: 'c1',
        tenantId: 't1',
        customerCode: 'CUS-1',
        firstName: 'Test',
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
  });

  setUp(() {
    repository = _MockCustomerRepository();
    audit = _MockAuditService();
    service = CustomerService(
      repository: repository,
      auditService: audit,
      permissionEngine: PermissionEngine(),
      numberGenerator: _MockNumberGenerator(),
      barcodeEngine: BarcodeEngine(),
    );
    when(() => repository.findByCode(any(), any())).thenAnswer((_) async => null);
    when(() => repository.create(any())).thenAnswer((inv) async => inv.positionalArguments[0] as Customer);
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
      draft: Customer(
        id: '',
        tenantId: 't1',
        customerCode: 'CUS-1',
        firstName: 'Test',
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
