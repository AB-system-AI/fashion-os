import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/entities/dashboard.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/entities/report.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/enums/analytics_enums.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/repositories/analytics_repositories.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/services/analytics_services.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';

class _MockScheduledRepo extends Mock implements ScheduledReportRepository {}

class _MockReportRepo extends Mock implements ReportRepository {}

class _MockExportService extends Mock implements AnalyticsExportService {}

class _MockAudit extends Mock implements AuditService {}

void main() {
  late ReportSchedulingService service;
  late _MockScheduledRepo scheduledRepo;
  late _MockReportRepo reportRepo;
  late _MockAudit audit;

  const user = AuthUser(
    userId: 'u1',
    employeeId: 'e1',
    email: 'a@b.com',
    emailVerified: true,
    tenantId: 't1',
    permissions: {ReportPermissions.schedule},
  );

  setUpAll(() {
    registerFallbackValue(
      ScheduledReport(
        id: 's1',
        tenantId: 't1',
        reportId: 'r1',
        frequency: ScheduleFrequency.daily,
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    registerFallbackValue(
      ReportExecutionHistory(
        id: 'h1',
        tenantId: 't1',
        scheduledReportId: 's1',
        status: ReportExecutionStatus.completed,
        version: 1,
        createdAt: DateTime.utc(2025),
        updatedAt: DateTime.utc(2025),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
  });

  setUp(() {
    scheduledRepo = _MockScheduledRepo();
    reportRepo = _MockReportRepo();
    audit = _MockAudit();
    service = ReportSchedulingService(
      repository: scheduledRepo,
      exportService: _MockExportService(),
      reportRepository: reportRepo,
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

  test('schedule creates scheduled report with next execution', () async {
    when(() => scheduledRepo.create(any())).thenAnswer((inv) async => inv.positionalArguments[0] as ScheduledReport);
    final result = await service.schedule(user: user, reportId: 'r1', frequency: ScheduleFrequency.daily);
    expect(result.isSuccess, isTrue);
    expect(result.dataOrNull?.nextExecutionAt, isNotNull);
  });

  test('executeNow updates schedule history', () async {
    final now = DateTime.utc(2025, 7, 12);
    final scheduled = ScheduledReport(
      id: 's1',
      tenantId: 't1',
      reportId: 'r1',
      frequency: ScheduleFrequency.weekly,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    when(() => reportRepo.getById('r1', tenantId: 't1')).thenAnswer((_) async => ReportDefinition(
          id: 'r1',
          tenantId: 't1',
          name: 'Weekly sales',
          module: 'sales',
          version: 1,
          createdAt: now,
          updatedAt: now,
          syncStatus: LocalSyncStatus.synced,
          isDirty: false,
        ));
    when(() => scheduledRepo.createExecution(any())).thenAnswer((inv) async => inv.positionalArguments[0] as ReportExecutionHistory);
    when(() => scheduledRepo.update(any())).thenAnswer((inv) async => inv.positionalArguments[0] as ScheduledReport);

    final result = await service.executeNow(user: user, scheduled: scheduled);
    expect(result.isSuccess, isTrue);
    verify(() => scheduledRepo.createExecution(any())).called(1);
  });
}
