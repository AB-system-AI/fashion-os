import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

class AutomationSettings extends Equatable implements SyncableEntity {
  const AutomationSettings({
    required this.id,
    required this.tenantId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.enableRules = true,
    this.enableWorkflows = true,
    this.enableScheduler = true,
    this.enableAiAssistant = false,
    this.maxConcurrentJobs = 5,
    this.defaultApprovalExpiryHours = 72,
    this.logRetentionDays = 90,
    this.deletedAt,
  });

  static const entityTypeName = 'automation_settings';

  @override
  final String id;
  @override
  final String tenantId;
  final bool enableRules;
  final bool enableWorkflows;
  final bool enableScheduler;
  final bool enableAiAssistant;
  final int maxConcurrentJobs;
  final int defaultApprovalExpiryHours;
  final int logRetentionDays;
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

  AutomationSettings copyWith({
    bool? enableRules,
    bool? enableWorkflows,
    bool? enableScheduler,
    bool? enableAiAssistant,
    int? maxConcurrentJobs,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      AutomationSettings(
        id: id,
        tenantId: tenantId,
        enableRules: enableRules ?? this.enableRules,
        enableWorkflows: enableWorkflows ?? this.enableWorkflows,
        enableScheduler: enableScheduler ?? this.enableScheduler,
        enableAiAssistant: enableAiAssistant ?? this.enableAiAssistant,
        maxConcurrentJobs: maxConcurrentJobs ?? this.maxConcurrentJobs,
        defaultApprovalExpiryHours: defaultApprovalExpiryHours,
        logRetentionDays: logRetentionDays,
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
        'enable_rules': enableRules,
        'enable_workflows': enableWorkflows,
        'enable_scheduler': enableScheduler,
        'enable_ai_assistant': enableAiAssistant,
        'max_concurrent_jobs': maxConcurrentJobs,
        'default_approval_expiry_hours': defaultApprovalExpiryHours,
        'log_retention_days': logRetentionDays,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static AutomationSettings fromPayload(Map<String, dynamic> json, LocalRecord record) => AutomationSettings(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        enableRules: json['enable_rules'] as bool? ?? true,
        enableWorkflows: json['enable_workflows'] as bool? ?? true,
        enableScheduler: json['enable_scheduler'] as bool? ?? true,
        enableAiAssistant: json['enable_ai_assistant'] as bool? ?? false,
        maxConcurrentJobs: json['max_concurrent_jobs'] as int? ?? 5,
        defaultApprovalExpiryHours: json['default_approval_expiry_hours'] as int? ?? 72,
        logRetentionDays: json['log_retention_days'] as int? ?? 90,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, tenantId, version];
}
