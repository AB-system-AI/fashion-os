import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/core/business/di/business_providers.dart';
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/accounting/presentation/providers/accounting_providers.dart';
import 'package:fashion_pos_enterprise/features/analytics/data/datasources/analytics_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/analytics/data/sync/analytics_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/entities/dashboard.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/entities/report.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/repositories/analytics_repositories.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/services/analytics_services.dart';
import 'package:fashion_pos_enterprise/features/customers/presentation/providers/customer_providers.dart';
import 'package:fashion_pos_enterprise/features/hr/presentation/providers/hr_providers.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/providers/manufacturing_providers.dart';
import 'package:fashion_pos_enterprise/features/pos/presentation/providers/pos_providers.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/providers/purchasing_providers.dart';

final analyticsRemoteDataSourceProvider = Provider<AnalyticsRemoteDataSource>((ref) => AnalyticsRemoteDataSource());

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final analyticsSnapshotRepositoryProvider = Provider<AnalyticsSnapshotRepository>((ref) {
  return AnalyticsSnapshotLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final kpiSnapshotRepositoryProvider = Provider<KpiSnapshotRepository>((ref) {
  return KpiSnapshotLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final scheduledReportRepositoryProvider = Provider<ScheduledReportRepository>((ref) {
  return ScheduledReportLocalRepository(database: ref.watch(appDatabaseProvider), syncQueue: ref.watch(syncQueueWriterProvider));
});

final dashboardServiceProvider = Provider<DashboardService>((ref) => DashboardService(
      engine: ref.watch(analyticsEngineProvider),
      permissions: ref.watch(permissionEngineProvider),
      sales: ref.watch(saleRepositoryProvider),
      stockLevels: ref.watch(stockLevelRepositoryProvider),
      purchasingReports: ref.watch(purchasingReportServiceProvider),
      customerAnalytics: ref.watch(customerAnalyticsServiceProvider),
      financialReports: ref.watch(financialReportServiceProvider),
      employees: ref.watch(employeeRepositoryProvider),
      manufacturingReports: ref.watch(manufacturingReportServiceProvider),
      snapshots: ref.watch(analyticsSnapshotRepositoryProvider),
    ));

final reportDefinitionServiceProvider = Provider<ReportDefinitionService>((ref) => ReportDefinitionService(
      repository: ref.watch(reportRepositoryProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final kpiServiceProvider = Provider<KpiService>((ref) => KpiService(
      engine: ref.watch(analyticsEngineProvider),
      repository: ref.watch(kpiSnapshotRepositoryProvider),
      dashboardService: ref.watch(dashboardServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final analyticsExportServiceProvider = Provider<AnalyticsExportService>((ref) => AnalyticsExportService(
      importExport: ref.watch(importExportServiceProvider),
      reports: ref.watch(reportRepositoryProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

final reportSchedulingServiceProvider = Provider<ReportSchedulingService>((ref) => ReportSchedulingService(
      repository: ref.watch(scheduledReportRepositoryProvider),
      exportService: ref.watch(analyticsExportServiceProvider),
      reportRepository: ref.watch(reportRepositoryProvider),
      audit: ref.watch(auditServiceProvider),
      permissions: ref.watch(permissionEngineProvider),
    ));

AnalyticsSyncProcessor _processor(Ref ref, String entityType, String table) => AnalyticsSyncProcessor(
      remote: ref.watch(analyticsRemoteDataSourceProvider),
      entityTypeName: entityType,
      remoteTable: table,
    );

final reportDefinitionSyncProcessorProvider = Provider<ReportSyncProcessor>(
  (ref) => _processor(ref, ReportDefinition.entityTypeName, 'report_definitions'),
);
final reportTemplateSyncProcessorProvider = Provider<ReportSyncProcessor>(
  (ref) => _processor(ref, ReportTemplate.entityTypeName, 'report_templates'),
);
final reportExportSyncProcessorProvider = Provider<ReportSyncProcessor>(
  (ref) => _processor(ref, ReportExport.entityTypeName, 'report_exports'),
);
final reportSnapshotSyncProcessorProvider = Provider<ReportSyncProcessor>(
  (ref) => _processor(ref, ReportSnapshot.entityTypeName, 'report_snapshots'),
);
final dashboardLayoutSyncProcessorProvider = Provider<DashboardSyncProcessor>(
  (ref) => _processor(ref, DashboardLayout.entityTypeName, 'dashboard_layouts'),
);
final dashboardWidgetSyncProcessorProvider = Provider<DashboardSyncProcessor>(
  (ref) => _processor(ref, DashboardWidget.entityTypeName, 'dashboard_widgets'),
);
final analyticsSnapshotSyncProcessorProvider = Provider<KpiSnapshotSyncProcessor>(
  (ref) => _processor(ref, AnalyticsSnapshot.entityTypeName, 'analytics_snapshots'),
);
final kpiSnapshotSyncProcessorProvider = Provider<KpiSnapshotSyncProcessor>(
  (ref) => _processor(ref, KpiSnapshot.entityTypeName, 'kpi_snapshots'),
);
final scheduledReportSyncProcessorProvider = Provider<KpiSnapshotSyncProcessor>(
  (ref) => _processor(ref, ScheduledReport.entityTypeName, 'scheduled_reports'),
);
final reportExecutionHistorySyncProcessorProvider = Provider<KpiSnapshotSyncProcessor>(
  (ref) => _processor(ref, ReportExecutionHistory.entityTypeName, 'report_execution_history'),
);
