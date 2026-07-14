import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';

class AutomationRule extends Equatable implements SyncableEntity {
  const AutomationRule({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.description,
    this.status = RuleStatus.draft,
    this.triggerEvent = TriggerEventType.manual,
    this.triggerEntityType,
    this.conditionField,
    this.conditionOperator,
    this.conditionValue,
    this.actionType,
    this.actionParameters = const {},
    this.priority = 0,
    this.createdBy,
    this.deletedAt,
  });

  static const entityTypeName = 'automation_rule';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? description;
  final RuleStatus status;
  final TriggerEventType triggerEvent;
  final String? triggerEntityType;
  final String? conditionField;
  final String? conditionOperator;
  final String? conditionValue;
  final String? actionType;
  final Map<String, dynamic> actionParameters;
  final int priority;
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

  bool get isActive => status == RuleStatus.active && deletedAt == null;

  @override
  String get entityType => entityTypeName;

  AutomationRule copyWith({
    RuleStatus? status,
    int? priority,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      AutomationRule(
        id: id,
        tenantId: tenantId,
        name: name,
        description: description,
        status: status ?? this.status,
        triggerEvent: triggerEvent,
        triggerEntityType: triggerEntityType,
        conditionField: conditionField,
        conditionOperator: conditionOperator,
        conditionValue: conditionValue,
        actionType: actionType,
        actionParameters: actionParameters,
        priority: priority ?? this.priority,
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
        'condition_field': conditionField,
        'condition_operator': conditionOperator,
        'condition_value': conditionValue,
        'action_type': actionType,
        'action_parameters': actionParameters,
        'priority': priority,
        'created_by': createdBy,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static AutomationRule fromPayload(Map<String, dynamic> json, LocalRecord record) => AutomationRule(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        description: json['description'] as String?,
        status: RuleStatus.fromValue(json['status'] as String?),
        triggerEvent: TriggerEventType.fromValue(json['trigger_event'] as String?),
        triggerEntityType: json['trigger_entity_type'] as String?,
        conditionField: json['condition_field'] as String?,
        conditionOperator: json['condition_operator'] as String?,
        conditionValue: json['condition_value'] as String?,
        actionType: json['action_type'] as String?,
        actionParameters: Map<String, dynamic>.from(json['action_parameters'] as Map? ?? {}),
        priority: json['priority'] as int? ?? 0,
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
