import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/entities/report.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/enums/analytics_enums.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/repositories/analytics_repositories.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/services/analytics_services.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';

class _MockReportRepository extends Mock implements ReportRepository {}

class _MockAuditService extends Mock implements AuditService {}

void main() {
  late ReportDefinitionService service;
  late _MockReportRepository repository;
  late _MockAuditService audit;

  const user = AuthUser(
    userId: 'u1',
    employeeId: 'e1',
    email: 'a@b.com',
    emailVerified: true,
    tenantId: 't1',
    permissions: {ReportPermissions.create},
  );

  setUpAll(() {
    registerFallbackValue(
      ReportDefinition(
        id: 'r1',
        tenantId: 't1',
        name: 'Test',
        module: 'sales',
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
  });

  setUp(() {
    repository = _MockReportRepository();
    audit = _MockAuditService();
    service = ReportDefinitionService(
      repository: repository,
      audit: audit,
      permissions: PermissionEngine(),
    );
    when(() => audit.log(
          action: any(named: 'action'),
          entityType: any(named: 'entityType'),
          tenantId: any(named: 'tenantId'),
          employeeId: any(named: 'employeeId'),
          entityId: any(named: 'entityId'),
          metadata: any(named: 'metadata'),
        )).thenAnswer((_) async {});
  });

  test('create requires reports.create permission', () async {
    const denied = AuthUser(
      userId: 'u1',
      employeeId: 'e1',
      email: 'a@b.com',
      emailVerified: true,
      tenantId: 't1',
      permissions: {},
    );
    final result = await service.create(
      user: denied,
      draft: ReportDefinition(
        id: '',
        tenantId: 't1',
        name: 'Denied',
        module: 'sales',
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    expect(result.isFailure, isTrue);
  });

  test('create persists report and audits', () async {
    when(() => repository.create(any())).thenAnswer((inv) async => inv.positionalArguments[0] as ReportDefinition);
    final now = DateTime.utc(2025, 7, 12);
    final result = await service.create(
      user: user,
      draft: ReportDefinition(
        id: '',
        tenantId: 't1',
        name: 'Sales KPI',
        module: 'sales',
        version: 1,
        createdAt: now,
        updatedAt: now,
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
        status: ReportStatus.draft,
      ),
    );
    expect(result.isSuccess, isTrue);
    verify(() => repository.create(any())).called(1);
    verify(() => audit.log(
          action: any(named: 'action'),
          entityType: ReportDefinition.entityTypeName,
          tenantId: 't1',
          employeeId: 'e1',
          entityId: any(named: 'entityId'),
          metadata: any(named: 'metadata'),
        )).called(1);
  });
}
