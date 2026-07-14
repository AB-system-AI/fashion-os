import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/entities/dashboard.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/entities/report.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/enums/analytics_enums.dart';

abstract class ReportRepository implements BaseLocalRepository<ReportDefinition> {
  Future<PaginatedResult<ReportDefinition>> listByModule(String tenantId, String module);
  Future<ReportTemplate> createTemplate(ReportTemplate template);
  Future<List<ReportTemplate>> listTemplates(String tenantId);
  Future<ReportExport> createExport(ReportExport export);
  Future<ReportSnapshot> createSnapshot(ReportSnapshot snapshot);
}

abstract class DashboardRepository implements BaseLocalRepository<DashboardLayout> {
  Future<List<DashboardLayout>> listByType(String tenantId, DashboardType type);
  Future<DashboardWidget> createWidget(DashboardWidget widget);
  Future<List<DashboardWidget>> listWidgets(String tenantId, String layoutId);
}

abstract class AnalyticsSnapshotRepository implements BaseLocalRepository<AnalyticsSnapshot> {
  Future<AnalyticsSnapshot?> latest(String tenantId, String snapshotType);
}

abstract class KpiSnapshotRepository implements BaseLocalRepository<KpiSnapshot> {
  Future<List<KpiSnapshot>> listByCategory(String tenantId, KpiCategory category);
}

abstract class ScheduledReportRepository implements BaseLocalRepository<ScheduledReport> {
  Future<List<ScheduledReport>> listActive(String tenantId);
  Future<ReportExecutionHistory> createExecution(ReportExecutionHistory history);
  Future<List<ReportExecutionHistory>> listExecutions(String tenantId, String scheduledReportId);
}
