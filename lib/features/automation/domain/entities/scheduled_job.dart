import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';

class ScheduledJob extends Equatable implements SyncableEntity {
  const ScheduledJob({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.description,
    this.scheduleType = JobScheduleType.once,
    this.cronExpression,
    this.intervalSeconds,
    this.runAt,
    this.timezone = 'UTC',
    this.status = JobStatus.pending,
    this.lastRunAt,
    this.nextRunAt,
    this.ruleId,
    this.workflowId,
    this.payload = const {},
    this.createdBy,
    this.deletedAt,
  });

  static const entityTypeName = 'scheduled_job';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? description;
  final JobScheduleType scheduleType;
  final String? cronExpression;
  final int? intervalSeconds;
  final DateTime? runAt;
  final String timezone;
  final JobStatus status;
  final DateTime? lastRunAt;
  final DateTime? nextRunAt;
  final String? ruleId;
  final String? workflowId;
  final Map<String, dynamic> payload;
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

  ScheduledJob copyWith({
    JobStatus? status,
    DateTime? lastRunAt,
    DateTime? nextRunAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      ScheduledJob(
        id: id,
        tenantId: tenantId,
        name: name,
        description: description,
        scheduleType: scheduleType,
        cronExpression: cronExpression,
        intervalSeconds: intervalSeconds,
        runAt: runAt,
        timezone: timezone,
        status: status ?? this.status,
        lastRunAt: lastRunAt ?? this.lastRunAt,
        nextRunAt: nextRunAt ?? this.nextRunAt,
        ruleId: ruleId,
        workflowId: workflowId,
        payload: payload,
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
        'schedule_type': scheduleType.value,
        'cron_expression': cronExpression,
        'interval_seconds': intervalSeconds,
        'run_at': runAt?.toIso8601String(),
        'timezone': timezone,
        'status': status.value,
        'last_run_at': lastRunAt?.toIso8601String(),
        'next_run_at': nextRunAt?.toIso8601String(),
        'rule_id': ruleId,
        'workflow_id': workflowId,
        'payload': payload,
        'created_by': createdBy,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ScheduledJob fromPayload(Map<String, dynamic> json, LocalRecord record) => ScheduledJob(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        description: json['description'] as String?,
        scheduleType: JobScheduleType.fromValue(json['schedule_type'] as String?),
        cronExpression: json['cron_expression'] as String?,
        intervalSeconds: json['interval_seconds'] as int?,
        runAt: json['run_at'] != null ? DateTime.tryParse(json['run_at'] as String) : null,
        timezone: json['timezone'] as String? ?? 'UTC',
        status: JobStatus.fromValue(json['status'] as String?),
        lastRunAt: json['last_run_at'] != null ? DateTime.tryParse(json['last_run_at'] as String) : null,
        nextRunAt: json['next_run_at'] != null ? DateTime.tryParse(json['next_run_at'] as String) : null,
        ruleId: json['rule_id'] as String?,
        workflowId: json['workflow_id'] as String?,
        payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
        createdBy: json['created_by'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, status, nextRunAt, version];
}

class JobQueueItem extends Equatable implements SyncableEntity {
  const JobQueueItem({
    required this.id,
    required this.tenantId,
    required this.scheduledJobId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = JobStatus.queued,
    this.priority = 0,
    this.attempts = 0,
    this.maxAttempts = 3,
    this.scheduledFor,
    this.startedAt,
    this.completedAt,
    this.errorMessage,
    this.payload = const {},
    this.deletedAt,
  });

  static const entityTypeName = 'job_queue_item';

  @override
  final String id;
  @override
  final String tenantId;
  final String scheduledJobId;
  final JobStatus status;
  final int priority;
  final int attempts;
  final int maxAttempts;
  final DateTime? scheduledFor;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? errorMessage;
  final Map<String, dynamic> payload;
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

  JobQueueItem copyWith({
    JobStatus? status,
    int? attempts,
    DateTime? startedAt,
    DateTime? completedAt,
    String? errorMessage,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      JobQueueItem(
        id: id,
        tenantId: tenantId,
        scheduledJobId: scheduledJobId,
        status: status ?? this.status,
        priority: priority,
        attempts: attempts ?? this.attempts,
        maxAttempts: maxAttempts,
        scheduledFor: scheduledFor,
        startedAt: startedAt ?? this.startedAt,
        completedAt: completedAt ?? this.completedAt,
        errorMessage: errorMessage ?? this.errorMessage,
        payload: payload,
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
        'scheduled_job_id': scheduledJobId,
        'status': status.value,
        'priority': priority,
        'attempts': attempts,
        'max_attempts': maxAttempts,
        'scheduled_for': scheduledFor?.toIso8601String(),
        'started_at': startedAt?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'error_message': errorMessage,
        'payload': payload,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static JobQueueItem fromPayload(Map<String, dynamic> json, LocalRecord record) => JobQueueItem(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        scheduledJobId: json['scheduled_job_id'] as String? ?? '',
        status: JobStatus.fromValue(json['status'] as String?),
        priority: json['priority'] as int? ?? 0,
        attempts: json['attempts'] as int? ?? 0,
        maxAttempts: json['max_attempts'] as int? ?? 3,
        scheduledFor: json['scheduled_for'] != null ? DateTime.tryParse(json['scheduled_for'] as String) : null,
        startedAt: json['started_at'] != null ? DateTime.tryParse(json['started_at'] as String) : null,
        completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
        errorMessage: json['error_message'] as String?,
        payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, scheduledJobId, status, version];
}
