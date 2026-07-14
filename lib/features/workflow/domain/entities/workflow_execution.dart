import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/enums/workflow_enums.dart';

/// Runtime workflow execution instance.
class WorkflowExecution extends Equatable implements SyncableEntity {
  const WorkflowExecution({
    required this.id,
    required this.tenantId,
    required this.templateId,
    required this.versionId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = WorkflowExecutionStatus.pending,
    this.currentStepIndex = 0,
    this.context = const {},
    this.startedAt,
    this.completedAt,
    this.errorMessage,
    this.deletedAt,
  });

  static const entityTypeName = 'wf_execution';

  @override
  final String id;
  @override
  final String tenantId;
  final String templateId;
  final String versionId;
  final WorkflowExecutionStatus status;
  final int currentStepIndex;
  final Map<String, dynamic> context;
  final DateTime? startedAt;
  final DateTime? completedAt;
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

  bool get isActive =>
      status == WorkflowExecutionStatus.pending || status == WorkflowExecutionStatus.running;

  WorkflowExecution copyWith({
    WorkflowExecutionStatus? status,
    int? currentStepIndex,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    DateTime? updatedAt,
    bool? isDirty,
    LocalSyncStatus? syncStatus,
  }) =>
      WorkflowExecution(
        id: id,
        tenantId: tenantId,
        templateId: templateId,
        versionId: versionId,
        status: status ?? this.status,
        currentStepIndex: currentStepIndex ?? this.currentStepIndex,
        context: context,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt ?? this.completedAt,
        errorMessage: errorMessage ?? this.errorMessage,
        version: version,
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
        'template_id': templateId,
        'version_id': versionId,
        'status': status.value,
        'current_step_index': currentStepIndex,
        'context': context,
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'error_message': errorMessage,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static WorkflowExecution fromPayload(Map<String, dynamic> json, LocalRecord record) => WorkflowExecution(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        templateId: json['template_id'] as String? ?? '',
        versionId: json['version_id'] as String? ?? '',
        status: WorkflowExecutionStatus.fromValue(json['status'] as String?),
        currentStepIndex: json['current_step_index'] as int? ?? 0,
        context: Map<String, dynamic>.from(json['context'] as Map? ?? {}),
        startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at'] as String) : null,
        completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
        errorMessage: json['error_message'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, templateId, status, currentStepIndex, version];
}

/// Execution log entry for audit and reports.
class WorkflowExecutionLog extends Equatable implements SyncableEntity {
  const WorkflowExecutionLog({
    required this.id,
    required this.tenantId,
    required this.executionId,
    required this.message,
    required this.occurredAt,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.stepIndex,
    this.level = 'info',
    this.data = const {},
    this.deletedAt,
  });

  static const entityTypeName = 'wf_execution_log';

  @override
  final String id;
  @override
  final String tenantId;
  final String executionId;
  final int? stepIndex;
  final String level;
  final String message;
  final Map<String, dynamic> data;
  final DateTime occurredAt;
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
        'execution_id': executionId,
        'step_index': stepIndex,
        'level': level,
        'message': message,
        'data': data,
        'occurred_at': occurredAt.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static WorkflowExecutionLog fromPayload(Map<String, dynamic> json, LocalRecord record) => WorkflowExecutionLog(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        executionId: json['execution_id'] as String? ?? '',
        stepIndex: json['step_index'] as int?,
        level: json['level'] as String? ?? 'info',
        message: json['message'] as String? ?? '',
        data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
        occurredAt: DateTime.tryParse(json['occurred_at'] as String? ?? '') ?? record.createdAt,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, executionId, message, occurredAt, version];
}

/// Aggregated workflow statistics for reporting.
class WorkflowStatistics extends Equatable implements SyncableEntity {
  const WorkflowStatistics({
    required this.id,
    required this.tenantId,
    required this.templateId,
    required this.periodStart,
    required this.periodEnd,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.totalExecutions = 0,
    this.completedCount = 0,
    this.failedCount = 0,
    this.avgDurationSeconds = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'wf_statistics';

  @override
  final String id;
  @override
  final String tenantId;
  final String templateId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalExecutions;
  final int completedCount;
  final int failedCount;
  final double avgDurationSeconds;
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

  double get successRate => totalExecutions == 0 ? 0 : completedCount / totalExecutions;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'template_id': templateId,
        'period_start': periodStart.toIso8601String(),
        'period_end': periodEnd.toIso8601String(),
        'total_executions': totalExecutions,
        'completed_count': completedCount,
        'failed_count': failedCount,
        'avg_duration_seconds': avgDurationSeconds,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static WorkflowStatistics fromPayload(Map<String, dynamic> json, LocalRecord record) => WorkflowStatistics(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        templateId: json['template_id'] as String? ?? '',
        periodStart: DateTime.tryParse(json['period_start'] as String? ?? '') ?? record.createdAt,
        periodEnd: DateTime.tryParse(json['period_end'] as String? ?? '') ?? record.updatedAt,
        totalExecutions: json['total_executions'] as int? ?? 0,
        completedCount: json['completed_count'] as int? ?? 0,
        failedCount: json['failed_count'] as int? ?? 0,
        avgDurationSeconds: (json['avg_duration_seconds'] as num?)?.toDouble() ?? 0,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, templateId, periodStart, totalExecutions, version];
}
