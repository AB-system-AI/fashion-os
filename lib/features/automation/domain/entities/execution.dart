import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';

class AutomationExecution extends Equatable implements SyncableEntity {
  const AutomationExecution({
    required this.id,
    required this.tenantId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.ruleId,
    this.workflowId,
    this.scheduledJobId,
    this.status = ExecutionStatus.pending,
    this.triggerEvent = TriggerEventType.manual,
    this.targetEntityType,
    this.targetEntityId,
    this.startedAt,
    this.completedAt,
    this.errorMessage,
    this.result = const {},
    this.deletedAt,
  });

  static const entityTypeName = 'automation_execution';

  @override
  final String id;
  @override
  final String tenantId;
  final String? ruleId;
  final String? workflowId;
  final String? scheduledJobId;
  final ExecutionStatus status;
  final TriggerEventType triggerEvent;
  final String? targetEntityType;
  final String? targetEntityId;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final Map<String, dynamic> result;
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

  AutomationExecution copyWith({
    ExecutionStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    Map<String, dynamic>? result,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      AutomationExecution(
        id: id,
        tenantId: tenantId,
        ruleId: ruleId,
        workflowId: workflowId,
        scheduledJobId: scheduledJobId,
        status: status ?? this.status,
        triggerEvent: triggerEvent,
        targetEntityType: targetEntityType,
        targetEntityId: targetEntityId,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt ?? this.completedAt,
        errorMessage: errorMessage ?? this.errorMessage,
        result: result ?? this.result,
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
        'rule_id': ruleId,
        'workflow_id': workflowId,
        'scheduled_job_id': scheduledJobId,
        'status': status.value,
        'trigger_event': triggerEvent.value,
        'entity_type': targetEntityType,
        'entity_id': targetEntityId,
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'error_message': errorMessage,
        'result': result,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static AutomationExecution fromPayload(Map<String, dynamic> json, LocalRecord record) => AutomationExecution(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        ruleId: json['rule_id'] as String?,
        workflowId: json['workflow_id'] as String?,
        scheduledJobId: json['scheduled_job_id'] as String?,
        status: ExecutionStatus.fromValue(json['status'] as String?),
        triggerEvent: TriggerEventType.fromValue(json['trigger_event'] as String?),
        targetEntityType: json['entity_type'] as String?,
        targetEntityId: json['entity_id'] as String?,
        startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at'] as String) : null,
        completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
        errorMessage: json['error_message'] as String?,
        result: Map<String, dynamic>.from(json['result'] as Map? ?? {}),
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, status, ruleId, workflowId, version];
}

class AutomationLog extends Equatable implements SyncableEntity {
  const AutomationLog({
    required this.id,
    required this.tenantId,
    required this.executionId,
    required this.message,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.level = LogLevel.info,
    this.metadata = const {},
    this.deletedAt,
  });

  static const entityTypeName = 'automation_log';

  @override
  final String id;
  @override
  final String tenantId;
  final String executionId;
  final LogLevel level;
  final String message;
  final Map<String, dynamic> metadata;
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
        'level': level.value,
        'message': message,
        'metadata': metadata,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static AutomationLog fromPayload(Map<String, dynamic> json, LocalRecord record) => AutomationLog(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        executionId: json['execution_id'] as String? ?? '',
        level: LogLevel.fromValue(json['level'] as String?),
        message: json['message'] as String? ?? '',
        metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, executionId, level, message, version];
}
