import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/enums/workflow_enums.dart';

/// Tenant-stored workflow definition (synced, distinct from in-memory [WorkflowDefinition]).
class TenantWorkflowDefinition extends Equatable implements SyncableEntity {
  const TenantWorkflowDefinition({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.workflowType,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.description,
    this.status = WorkflowDefinitionStatus.draft,
    this.steps = const [],
    this.createdBy,
    this.deletedAt,
  });

  static const entityTypeName = 'wf_definition';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? description;
  final String workflowType;
  final WorkflowDefinitionStatus status;
  final List<Map<String, dynamic>> steps;
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

  @override
  String get entityType => entityTypeName;

  bool get isActive => status == WorkflowDefinitionStatus.active;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'name': name,
        'description': description,
        'workflow_type': workflowType,
        'status': status.value,
        'steps': steps,
        'created_by': createdBy,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static TenantWorkflowDefinition fromPayload(Map<String, dynamic> json, LocalRecord record) => TenantWorkflowDefinition(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        description: json['description'] as String?,
        workflowType: json['workflow_type'] as String? ?? 'approval',
        status: WorkflowDefinitionStatus.fromValue(json['status'] as String?),
        steps: List<Map<String, dynamic>>.from(
          (json['steps'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
        ),
        createdBy: json['created_by'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, workflowType, status, version];
}

/// Running workflow instance stored per tenant.
class TenantWorkflowInstance extends Equatable implements SyncableEntity {
  const TenantWorkflowInstance({
    required this.id,
    required this.tenantId,
    required this.definitionId,
    required this.entityId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = WorkflowInstanceStatus.pending,
    this.currentStepIndex = 0,
    this.startedAt,
    this.completedAt,
    this.metadata = const {},
    this.deletedAt,
  });

  static const entityTypeName = 'wf_instance';

  @override
  final String id;
  @override
  final String tenantId;
  final String definitionId;
  final String entityId;
  final WorkflowInstanceStatus status;
  final int currentStepIndex;
  final DateTime? startedAt;
  final DateTime? completedAt;
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

  bool get isActive =>
      status == WorkflowInstanceStatus.pending || status == WorkflowInstanceStatus.inProgress;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'definition_id': definitionId,
        'entity_id': entityId,
        'status': status.value,
        'current_step_index': currentStepIndex,
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'metadata': metadata,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static TenantWorkflowInstance fromPayload(Map<String, dynamic> json, LocalRecord record) => TenantWorkflowInstance(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        definitionId: json['definition_id'] as String? ?? '',
        entityId: json['entity_id'] as String? ?? '',
        status: WorkflowInstanceStatus.fromValue(json['status'] as String?),
        currentStepIndex: json['current_step_index'] as int? ?? 0,
        startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at'] as String) : null,
        completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
        metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, definitionId, entityId, status, version];
}
