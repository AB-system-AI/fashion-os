import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';

class AutomationWorkflow extends Equatable implements SyncableEntity {
  const AutomationWorkflow({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.description,
    this.status = WorkflowStatus.draft,
    this.triggerEvent = TriggerEventType.manual,
    this.triggerEntityType,
    this.createdBy,
    this.deletedAt,
  });

  static const entityTypeName = 'automation_workflow';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? description;
  final WorkflowStatus status;
  final TriggerEventType triggerEvent;
  final String? triggerEntityType;
  final String? createdBy;
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

  bool get isActive => status == WorkflowStatus.active && deletedAt == null;

  @override
  String get entityType => entityTypeName;

  AutomationWorkflow copyWith({
    WorkflowStatus? status,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      AutomationWorkflow(
        id: id,
        tenantId: tenantId,
        name: name,
        description: description,
        status: status ?? this.status,
        triggerEvent: triggerEvent,
        triggerEntityType: triggerEntityType,
        createdBy: createdBy,
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
        'name': name,
        'description': description,
        'status': status.value,
        'trigger_event': triggerEvent.value,
        'trigger_entity_type': triggerEntityType,
        'created_by': createdBy,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static AutomationWorkflow fromPayload(Map<String, dynamic> json, LocalRecord record) => AutomationWorkflow(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        description: json['description'] as String?,
        status: WorkflowStatus.fromValue(json['status'] as String?),
        triggerEvent: TriggerEventType.fromValue(json['trigger_event'] as String?),
        triggerEntityType: json['trigger_entity_type'] as String?,
        createdBy: json['created_by'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, status, version];
}

class WorkflowStep extends Equatable implements SyncableEntity {
  const WorkflowStep({
    required this.id,
    required this.tenantId,
    required this.workflowId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.stepType = WorkflowStepType.action,
    this.stepOrder = 0,
    this.config = const {},
    this.requiredRole,
    this.deletedAt,
  });

  static const entityTypeName = 'workflow_step';

  @override
  final String id;
  @override
  final String tenantId;
  final String workflowId;
  final String name;
  final WorkflowStepType stepType;
  final int stepOrder;
  final Map<String, dynamic> config;
  final String? requiredRole;
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
        'workflow_id': workflowId,
        'name': name,
        'step_type': stepType.value,
        'step_order': stepOrder,
        'config': config,
        'required_role': requiredRole,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static WorkflowStep fromPayload(Map<String, dynamic> json, LocalRecord record) => WorkflowStep(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        workflowId: json['workflow_id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        stepType: WorkflowStepType.fromValue(json['step_type'] as String?),
        stepOrder: json['step_order'] as int? ?? 0,
        config: Map<String, dynamic>.from(json['config'] as Map? ?? {}),
        requiredRole: json['required_role'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, workflowId, stepOrder, version];
}
