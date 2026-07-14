import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/enums/analytics_enums.dart';

class DashboardLayout extends Equatable implements SyncableEntity {
  const DashboardLayout({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.dashboardType,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.isDefault = false,
    this.storeId,
    this.deletedAt,
  });

  static const entityTypeName = 'dashboard_layout';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final DashboardType dashboardType;
  final bool isDefault;
  final String? storeId;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'name': name,
        'dashboard_type': dashboardType.value,
        'is_default': isDefault,
        'store_id': storeId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static DashboardLayout fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return DashboardLayout(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      name: json['name'] as String? ?? '',
      dashboardType: DashboardType.fromValue(json['dashboard_type'] as String?),
      isDefault: json['is_default'] as bool? ?? false,
      storeId: json['store_id'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, name, version];
}

class DashboardWidget extends Equatable implements SyncableEntity {
  const DashboardWidget({
    required this.id,
    required this.tenantId,
    required this.layoutId,
    required this.title,
    required this.widgetType,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.chartType = ChartType.bar,
    this.config = const {},
    this.position = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'dashboard_widget';

  @override
  final String id;
  @override
  final String tenantId;
  final String layoutId;
  final String title;
  final String widgetType;
  final ChartType chartType;
  final Map<String, dynamic> config;
  final int position;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'layout_id': layoutId,
        'title': title,
        'widget_type': widgetType,
        'chart_type': chartType.value,
        'config': config,
        'position': position,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static DashboardWidget fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return DashboardWidget(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      layoutId: json['layout_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      widgetType: json['widget_type'] as String? ?? 'metric',
      chartType: ChartType.fromValue(json['chart_type'] as String?),
      config: Map<String, dynamic>.from(json['config'] as Map? ?? {}),
      position: json['position'] as int? ?? 0,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, layoutId, version];
}

class AnalyticsSnapshot extends Equatable implements SyncableEntity {
  const AnalyticsSnapshot({
    required this.id,
    required this.tenantId,
    required this.snapshotType,
    required this.metrics,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.storeId,
    this.deletedAt,
  });

  static const entityTypeName = 'analytics_snapshot';

  @override
  final String id;
  @override
  final String tenantId;
  final String snapshotType;
  final Map<String, dynamic> metrics;
  final String? storeId;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'snapshot_type': snapshotType,
        'metrics': metrics,
        'store_id': storeId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static AnalyticsSnapshot fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return AnalyticsSnapshot(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      snapshotType: json['snapshot_type'] as String? ?? 'executive',
      metrics: Map<String, dynamic>.from(json['metrics'] as Map? ?? {}),
      storeId: json['store_id'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, snapshotType, version];
}

class KpiSnapshot extends Equatable implements SyncableEntity {
  const KpiSnapshot({
    required this.id,
    required this.tenantId,
    required this.category,
    required this.kpiCode,
    required this.value,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.unit,
    this.periodStart,
    this.periodEnd,
    this.deletedAt,
  });

  static const entityTypeName = 'kpi_snapshot';

  @override
  final String id;
  @override
  final String tenantId;
  final KpiCategory category;
  final String kpiCode;
  final double value;
  final String? unit;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'category': category.value,
        'kpi_code': kpiCode,
        'value': value,
        'unit': unit,
        'period_start': periodStart?.toIso8601String(),
        'period_end': periodEnd?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static KpiSnapshot fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return KpiSnapshot(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      category: KpiCategory.fromValue(json['category'] as String?),
      kpiCode: json['kpi_code'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String?,
      periodStart: json['period_start'] != null ? DateTime.tryParse(json['period_start'] as String) : null,
      periodEnd: json['period_end'] != null ? DateTime.tryParse(json['period_end'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, kpiCode, value, version];
}

class ScheduledReport extends Equatable implements SyncableEntity {
  const ScheduledReport({
    required this.id,
    required this.tenantId,
    required this.reportId,
    required this.frequency,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.isActive = true,
    this.recipientEmail,
    this.lastExecutedAt,
    this.nextExecutionAt,
    this.deletedAt,
  });

  static const entityTypeName = 'scheduled_report';

  @override
  final String id;
  @override
  final String tenantId;
  final String reportId;
  final ScheduleFrequency frequency;
  final bool isActive;
  final String? recipientEmail;
  final DateTime? lastExecutedAt;
  final DateTime? nextExecutionAt;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  ScheduledReport copyWith({
    DateTime? lastExecutedAt,
    DateTime? nextExecutionAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      ScheduledReport(
        id: id,
        tenantId: tenantId,
        reportId: reportId,
        frequency: frequency,
        isActive: isActive,
        recipientEmail: recipientEmail,
        lastExecutedAt: lastExecutedAt ?? this.lastExecutedAt,
        nextExecutionAt: nextExecutionAt ?? this.nextExecutionAt,
        version: version ?? this.version,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDirty: isDirty ?? this.isDirty,
      );

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'report_id': reportId,
        'frequency': frequency.value,
        'is_active': isActive,
        'recipient_email': recipientEmail,
        'last_executed_at': lastExecutedAt?.toIso8601String(),
        'next_execution_at': nextExecutionAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ScheduledReport fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return ScheduledReport(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      reportId: json['report_id'] as String? ?? '',
      frequency: ScheduleFrequency.fromValue(json['frequency'] as String?),
      isActive: json['is_active'] as bool? ?? true,
      recipientEmail: json['recipient_email'] as String?,
      lastExecutedAt: json['last_executed_at'] != null ? DateTime.tryParse(json['last_executed_at'] as String) : null,
      nextExecutionAt: json['next_execution_at'] != null ? DateTime.tryParse(json['next_execution_at'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, reportId, version];
}

class ReportExecutionHistory extends Equatable implements SyncableEntity {
  const ReportExecutionHistory({
    required this.id,
    required this.tenantId,
    required this.scheduledReportId,
    required this.status,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.executedAt,
    this.errorMessage,
    this.deletedAt,
  });

  static const entityTypeName = 'report_execution_history';

  @override
  final String id;
  @override
  final String tenantId;
  final String scheduledReportId;
  final ReportExecutionStatus status;
  final DateTime? executedAt;
  final String? errorMessage;
  @override
  final int version;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final LocalSyncStatus syncStatus;
  @override
  final bool isDirty;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'scheduled_report_id': scheduledReportId,
        'status': status.value,
        'executed_at': executedAt?.toIso8601String(),
        'error_message': errorMessage,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ReportExecutionHistory fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return ReportExecutionHistory(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      scheduledReportId: json['scheduled_report_id'] as String? ?? '',
      status: ReportExecutionStatus.fromValue(json['status'] as String?),
      executedAt: json['executed_at'] != null ? DateTime.tryParse(json['executed_at'] as String) : null,
      errorMessage: json['error_message'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, scheduledReportId, status, version];
}
