import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/engines/integration/integration_connector_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/entities/connector.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/enums/integration_enums.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/repositories/integration_repositories.dart';
import 'package:fashion_pos_enterprise/features/integrations/domain/services/integration_services.dart';

class _MockConnectorRepo extends Mock implements IntegrationConnectorRepository {}

class _MockAudit extends Mock implements AuditService {}

class _MockPermissions extends Mock implements PermissionEngine {}

class _MockLogs extends Mock implements IntegrationLogService {}

void main() {
  late _MockConnectorRepo repo;
  late ConnectorService service;
  late AuthUser user;

  setUp(() {
    repo = _MockConnectorRepo();
    final audit = _MockAudit();
    final permissions = _MockPermissions();
    final logs = _MockLogs();
    when(() => permissions.require(any(), any())).thenReturn(null);
    when(() => audit.log(
          action: any(named: 'action'),
          entityType: any(named: 'entityType'),
          tenantId: any(named: 'tenantId'),
          employeeId: any(named: 'employeeId'),
          entityId: any(named: 'entityId'),
          metadata: any(named: 'metadata'),
        )).thenAnswer((_) async {});
    service = ConnectorService(
      repository: repo,
      engine: IntegrationConnectorEngine(),
      audit: audit,
      permissions: permissions,
      logs: logs,
    );
    user = const AuthUser(userId: 'u1', email: 'a@b.com', emailVerified: true, tenantId: 't1', employeeId: 'e1');
  });

  test('create connector persists and returns success', () async {
    when(() => repo.create(any())).thenAnswer((inv) async => inv.positionalArguments[0] as IntegrationConnector);
    final result = await service.create(user: user, name: 'SendGrid', type: ConnectorType.email, providerKey: 'sendgrid');
    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull!.name, 'SendGrid');
    expect(result.dataOrNull!.connectorType, ConnectorType.email);
  });

  test('recordSuccess resets consecutive failures', () async {
    final now = DateTime.now().toUtc();
    final connector = IntegrationConnector(
      id: 'c1',
      tenantId: 't1',
      name: 'Test',
      connectorType: ConnectorType.email,
      consecutiveFailures: 2,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    when(() => repo.update(any())).thenAnswer((inv) async => inv.positionalArguments[0] as IntegrationConnector);
    final result = await service.recordSuccess(connector);
    expect(result.dataOrNull!.consecutiveFailures, 0);
    expect(result.dataOrNull!.status, ConnectorStatus.active);
  });

  test('list returns paginated connectors', () async {
    when(() => repo.getPage(any())).thenAnswer((_) async => const PaginatedResult(items: [], totalCount: 0));
    final page = await service.list('t1');
    expect(page.items, isEmpty);
  });
}
