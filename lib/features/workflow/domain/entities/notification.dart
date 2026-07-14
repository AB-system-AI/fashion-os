import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/enums/workflow_enums.dart';

/// In-app notification center item.
class NotificationCenterItem extends Equatable implements SyncableEntity {
  const NotificationCenterItem({
    required this.id,
    required this.tenantId,
    required this.recipientId,
    required this.title,
    required this.body,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = NotificationItemStatus.unread,
    this.priority = NotificationPriority.normal,
    this.channel = 'in_app',
    this.sourceType,
    this.sourceId,
    this.readAt,
    this.data = const {},
    this.deletedAt,
  });

  static const entityTypeName = 'wf_notification';

  @override
  final String id;
  @override
  final String tenantId;
  final String recipientId;
  final String title;
  final String body;
  final NotificationItemStatus status;
  final NotificationPriority priority;
  final String channel;
  final String? sourceType;
  final String? sourceId;
  final DateTime? readAt;
  final Map<String, dynamic> data;
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

  NotificationCenterItem copyWith({
    NotificationItemStatus? status,
    DateTime? readAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      NotificationCenterItem(
        id: id,
        tenantId: tenantId,
        recipientId: recipientId,
        title: title,
        body: body,
        status: status ?? this.status,
        priority: priority,
        channel: channel,
        sourceType: sourceType,
        sourceId: sourceId,
        readAt: readAt ?? this.readAt,
        data: data,
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
        'recipient_id': recipientId,
        'title': title,
        'body': body,
        'status': status.value,
        'priority': priority.value,
        'channel': channel,
        'source_type': sourceType,
        'source_id': sourceId,
        'read_at': readAt?.toIso8601String(),
        'data': data,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static NotificationCenterItem fromPayload(Map<String, dynamic> json, LocalRecord record) => NotificationCenterItem(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        recipientId: json['recipient_id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        status: NotificationItemStatus.fromValue(json['status'] as String?),
        priority: NotificationPriority.fromValue(json['priority'] as String?),
        channel: json['channel'] as String? ?? 'in_app',
        sourceType: json['source_type'] as String?,
        sourceId: json['source_id'] as String?,
        readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'] as String) : null,
        data: Map<String, dynamic>.from(json['data'] as Map? ?? {}),
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, recipientId, status, version];
}

/// Scheduled reminder rule for pending approvals.
class ReminderRule extends Equatable implements SyncableEntity {
  const ReminderRule({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.scheduleType = ReminderScheduleType.interval,
    this.intervalHours = 24,
    this.cronExpression,
    this.targetEntityType,
    this.isActive = true,
    this.deletedAt,
  });

  static const entityTypeName = 'wf_reminder_rule';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final ReminderScheduleType scheduleType;
  final int intervalHours;
  final String? cronExpression;
  final String? targetEntityType;
  final bool isActive;
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
        'schedule_type': scheduleType.value,
        'interval_hours': intervalHours,
        'cron_expression': cronExpression,
        'target_entity_type': targetEntityType,
        'is_active': isActive,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ReminderRule fromPayload(Map<String, dynamic> json, LocalRecord record) => ReminderRule(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        scheduleType: ReminderScheduleType.fromValue(json['schedule_type'] as String?),
        intervalHours: json['interval_hours'] as int? ?? 24,
        cronExpression: json['cron_expression'] as String?,
        targetEntityType: json['target_entity_type'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, isActive, version];
}

/// Escalation rule when approvals time out.
class EscalationRule extends Equatable implements SyncableEntity {
  const EscalationRule({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.triggerType = EscalationTriggerType.timeout,
    this.timeoutHours = 48,
    this.escalateToRole,
    this.targetEntityType,
    this.isActive = true,
    this.deletedAt,
  });

  static const entityTypeName = 'wf_escalation_rule';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final EscalationTriggerType triggerType;
  final int timeoutHours;
  final String? escalateToRole;
  final String? targetEntityType;
  final bool isActive;
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
        'trigger_type': triggerType.value,
        'timeout_hours': timeoutHours,
        'escalate_to_role': escalateToRole,
        'target_entity_type': targetEntityType,
        'is_active': isActive,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static EscalationRule fromPayload(Map<String, dynamic> json, LocalRecord record) => EscalationRule(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        triggerType: EscalationTriggerType.fromValue(json['trigger_type'] as String?),
        timeoutHours: json['timeout_hours'] as int? ?? 48,
        escalateToRole: json['escalate_to_role'] as String?,
        targetEntityType: json['target_entity_type'] as String?,
        isActive: json['is_active'] as bool? ?? true,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, timeoutHours, isActive, version];
}

/// Reference linking workflow notifications to automation rules.
class AutomationRuleRef extends Equatable {
  const AutomationRuleRef({
    required this.ruleId,
    required this.ruleName,
    this.triggerEvent,
  });

  final String ruleId;
  final String ruleName;
  final String? triggerEvent;

  @override
  List<Object?> get props => [ruleId, ruleName];
}
