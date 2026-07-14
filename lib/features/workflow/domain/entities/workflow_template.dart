import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/enums/workflow_enums.dart';

/// Visual workflow template (designer).
class WorkflowTemplate extends Equatable implements SyncableEntity {
  const WorkflowTemplate({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.description,
    this.categoryId,
    this.status = WorkflowDefinitionStatus.draft,
    this.createdBy,
    this.deletedAt,
  });

  static const entityTypeName = 'wf_template';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? description;
  final String? categoryId;
  final WorkflowDefinitionStatus status;
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

  WorkflowTemplate copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    WorkflowDefinitionStatus? status,
    int? version,
    DateTime? updatedAt,
    bool? isDirty,
    LocalSyncStatus? syncStatus,
  }) =>
      WorkflowTemplate(
        id: id ?? this.id,
        tenantId: tenantId,
        name: name ?? this.name,
        description: description ?? this.description,
        categoryId: categoryId ?? this.categoryId,
        status: status ?? this.status,
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
        'category_id': categoryId,
        'status': status.value,
        'created_by': createdBy,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static WorkflowTemplate fromPayload(Map<String, dynamic> json, LocalRecord record) => WorkflowTemplate(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        description: json['description'] as String?,
        categoryId: json['category_id'] as String?,
        status: WorkflowDefinitionStatus.fromValue(json['status'] as String?),
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

/// Versioned workflow definition with steps.
class WorkflowVersion extends Equatable implements SyncableEntity {
  const WorkflowVersion({
    required this.id,
    required this.tenantId,
    required this.templateId,
    required this.versionNumber,
    required this.status,
    required this.steps,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.variables = const [],
    this.conditions = const [],
    this.publishedAt,
    this.archivedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'wf_template_version';

  @override
  final String id;
  @override
  final String tenantId;
  final String templateId;
  final int versionNumber;
  final WorkflowVersionStatus status;
  final List<WorkflowAction> steps;
  final List<WorkflowVariable> variables;
  final List<WorkflowCondition> conditions;
  final DateTime? publishedAt;
  final DateTime? archivedAt;
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

  WorkflowVersion copyWith({
    WorkflowVersionStatus? status,
    List<WorkflowAction>? steps,
    DateTime? publishedAt,
    DateTime? archivedAt,
    DateTime? updatedAt,
    bool? isDirty,
  }) =>
      WorkflowVersion(
        id: id,
        tenantId: tenantId,
        templateId: templateId,
        versionNumber: versionNumber,
        status: status ?? this.status,
        steps: steps ?? this.steps,
        variables: variables,
        conditions: conditions,
        publishedAt: publishedAt ?? this.publishedAt,
        archivedAt: archivedAt ?? this.archivedAt,
        version: version,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt,
        syncStatus: syncStatus,
        isDirty: isDirty ?? this.isDirty,
      );

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'template_id': templateId,
        'version_number': versionNumber,
        'status': status.value,
        'steps': steps.map((s) => s.toJson()).toList(),
        'variables': variables.map((v) => v.toPayload()).toList(),
        'conditions': conditions.map((c) => c.toJson()).toList(),
        'published_at': publishedAt?.toIso8601String(),
        'archived_at': archivedAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static WorkflowVersion fromPayload(Map<String, dynamic> json, LocalRecord record) => WorkflowVersion(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        templateId: json['template_id'] as String? ?? '',
        versionNumber: json['version_number'] as int? ?? 1,
        status: WorkflowVersionStatus.fromValue(json['status'] as String?),
        steps: (json['steps'] as List? ?? [])
            .map((s) => WorkflowAction.fromJson(Map<String, dynamic>.from(s as Map)))
            .toList(),
        variables: (json['variables'] as List? ?? [])
            .map((v) => WorkflowVariable.fromPayload(Map<String, dynamic>.from(v as Map), tenantId: record.tenantId))
            .toList(),
        conditions: (json['conditions'] as List? ?? [])
            .map((c) => WorkflowCondition.fromJson(Map<String, dynamic>.from(c as Map)))
            .toList(),
        publishedAt: json['published_at'] != null ? DateTime.tryParse(json['published_at'] as String) : null,
        archivedAt: json['archived_at'] != null ? DateTime.tryParse(json['archived_at'] as String) : null,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  static WorkflowVersion fromPayloadMap(Map<String, dynamic> json, {required String tenantId}) {
    final now = DateTime.now().toUtc();
    return WorkflowVersion(
      id: json['id'] as String? ?? '',
      tenantId: tenantId,
      templateId: json['template_id'] as String? ?? '',
      versionNumber: json['version_number'] as int? ?? 1,
      status: WorkflowVersionStatus.fromValue(json['status'] as String?),
      steps: (json['steps'] as List? ?? [])
          .map((s) => WorkflowAction.fromJson(Map<String, dynamic>.from(s as Map)))
          .toList(),
      variables: const [],
      conditions: const [],
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
  }

  @override
  List<Object?> get props => [id, templateId, versionNumber, status, version];
}

/// Workflow category for grouping templates.
class WorkflowCategory extends Equatable implements SyncableEntity {
  const WorkflowCategory({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.description,
    this.color,
    this.deletedAt,
  });

  static const entityTypeName = 'wf_category';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? description;
  final String? color;
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
        'description': description,
        'color': color,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static WorkflowCategory fromPayload(Map<String, dynamic> json, LocalRecord record) => WorkflowCategory(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        description: json['description'] as String?,
        color: json['color'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, version];
}

/// Template variable for simulation and runtime context.
class WorkflowVariable extends Equatable {
  const WorkflowVariable({
    required this.key,
    required this.label,
    this.defaultValue,
    this.variableType = 'string',
    this.isRequired = false,
  });

  final String key;
  final String label;
  final dynamic defaultValue;
  final String variableType;
  final bool isRequired;

  Map<String, dynamic> toPayload() => {
        'key': key,
        'label': label,
        'default_value': defaultValue,
        'variable_type': variableType,
        'is_required': isRequired,
      };

  static WorkflowVariable fromPayload(Map<String, dynamic> json, {required String tenantId}) => WorkflowVariable(
        key: json['key'] as String? ?? '',
        label: json['label'] as String? ?? '',
        defaultValue: json['default_value'],
        variableType: json['variable_type'] as String? ?? 'string',
        isRequired: json['is_required'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [key, label, variableType];
}

/// Conditional branch in a workflow version.
class WorkflowCondition extends Equatable {
  const WorkflowCondition({
    required this.field,
    required this.operator,
    this.value,
    this.stepIndex,
  });

  final String field;
  final ConditionOperator operator;
  final dynamic value;
  final int? stepIndex;

  Map<String, dynamic> toJson() => {
        'field': field,
        'operator': operator.value,
        'value': value,
        'step_index': stepIndex,
      };

  static WorkflowCondition fromJson(Map<String, dynamic> json) => WorkflowCondition(
        field: json['field'] as String? ?? '',
        operator: ConditionOperator.fromValue(json['operator'] as String?),
        value: json['value'],
        stepIndex: json['step_index'] as int?,
      );

  @override
  List<Object?> get props => [field, operator, value, stepIndex];
}

/// Designer step with nested actions.
class WorkflowAction extends Equatable {
  const WorkflowAction({
    required this.id,
    required this.name,
    required this.order,
    this.actions = const [],
    this.config = const {},
  });

  final String id;
  final String name;
  final int order;
  final List<WorkflowStepAction> actions;
  final Map<String, dynamic> config;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'order': order,
        'actions': actions.map((a) => a.toJson()).toList(),
        'config': config,
      };

  static WorkflowAction fromJson(Map<String, dynamic> json) => WorkflowAction(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        order: json['order'] as int? ?? 0,
        actions: (json['actions'] as List? ?? [])
            .map((a) => WorkflowStepAction.fromJson(Map<String, dynamic>.from(a as Map)))
            .toList(),
        config: Map<String, dynamic>.from(json['config'] as Map? ?? {}),
      );

  @override
  List<Object?> get props => [id, name, order];
}

/// Atomic action within a workflow step.
class WorkflowStepAction extends Equatable {
  const WorkflowStepAction({
    required this.actionType,
    this.config = const {},
  });

  final WorkflowActionType actionType;
  final Map<String, dynamic> config;

  Map<String, dynamic> toJson() => {
        'action_type': actionType.value,
        'config': config,
      };

  static WorkflowStepAction fromJson(Map<String, dynamic> json) => WorkflowStepAction(
        actionType: WorkflowActionType.fromValue(json['action_type'] as String?),
        config: Map<String, dynamic>.from(json['config'] as Map? ?? {}),
      );

  @override
  List<Object?> get props => [actionType];
}
