import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/enums/workflow_enums.dart';

/// Scheduled workflow/automation job record.
class ScheduledJobRecord extends Equatable implements SyncableEntity {
  const ScheduledJobRecord({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.jobType,
    required this.scheduleType,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = JobStatus.pending,
    this.cronExpression,
    this.intervalSeconds,
    this.runAt,
    this.nextRunAt,
    this.lastRunAt,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.retryDelaySeconds = 60,
    this.payload = const {},
    this.deletedAt,
  });

  static const entityTypeName = 'scheduler_job';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String jobType;
  final JobScheduleType scheduleType;
  final JobStatus status;
  final String? cronExpression;
  final int? intervalSeconds;
  final DateTime? runAt;
  final DateTime? nextRunAt;
  final DateTime? lastRunAt;
  final int retryCount;
  final int maxRetries;
  final int retryDelaySeconds;
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

  ScheduledJobRecord copyWith({
    JobStatus? status,
    DateTime? nextRunAt,
    DateTime? lastRunAt,
    int? retryCount,
    DateTime? updatedAt,
    bool? isDirty,
    LocalSyncStatus? syncStatus,
  }) =>
      ScheduledJobRecord(
        id: id,
        tenantId: tenantId,
        name: name,
        jobType: jobType,
        scheduleType: scheduleType,
        status: status ?? this.status,
        cronExpression: cronExpression,
        intervalSeconds: intervalSeconds,
        runAt: runAt,
        nextRunAt: nextRunAt ?? this.nextRunAt,
        lastRunAt: lastRunAt ?? this.lastRunAt,
        retryCount: retryCount ?? this.retryCount,
        maxRetries: maxRetries,
        retryDelaySeconds: retryDelaySeconds,
        payload: payload,
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
        'name': name,
        'job_type': jobType,
        'schedule_type': scheduleType.value,
        'status': status.value,
        'cron_expression': cronExpression,
        'interval_seconds': intervalSeconds,
        'run_at': runAt?.toIso8601String(),
        'next_run_at': nextRunAt?.toIso8601String(),
        'last_run_at': lastRunAt?.toIso8601String(),
        'retry_count': retryCount,
        'max_retries': maxRetries,
        'retry_delay_seconds': retryDelaySeconds,
        'payload': payload,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ScheduledJobRecord fromPayload(Map<String, dynamic> json, LocalRecord record) => ScheduledJobRecord(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        name: json['name'] as String? ?? record.searchName ?? '',
        jobType: json['job_type'] as String? ?? 'workflow',
        scheduleType: JobScheduleType.fromValue(json['schedule_type'] as String?),
        status: JobStatus.fromValue(json['status'] as String?),
        cronExpression: json['cron_expression'] as String?,
        intervalSeconds: json['interval_seconds'] as int?,
        runAt: json['run_at'] != null ? DateTime.tryParse(json['run_at'] as String) : null,
        nextRunAt: json['next_run_at'] != null ? DateTime.tryParse(json['next_run_at'] as String) : null,
        lastRunAt: json['last_run_at'] != null ? DateTime.tryParse(json['last_run_at'] as String) : null,
        retryCount: json['retry_count'] as int? ?? 0,
        maxRetries: json['max_retries'] as int? ?? 3,
        retryDelaySeconds: json['retry_delay_seconds'] as int? ?? 60,
        payload: Map<String, dynamic>.from(json['payload'] as Map? ?? {}),
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, name, scheduleType, status, nextRunAt, version];
}

/// Log entry for a scheduler job run.
class JobExecutionLog extends Equatable implements SyncableEntity {
  const JobExecutionLog({
    required this.id,
    required this.tenantId,
    required this.jobId,
    required this.startedAt,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.completedAt,
    this.success = true,
    this.errorMessage,
    this.deletedAt,
  });

  static const entityTypeName = 'scheduler_execution_log';

  @override
  final String id;
  @override
  final String tenantId;
  final String jobId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final bool success;
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

  Duration? get duration => completedAt != null ? completedAt!.difference(startedAt) : null;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'job_id': jobId,
        'started_at': startedAt.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'success': success,
        'error_message': errorMessage,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static JobExecutionLog fromPayload(Map<String, dynamic> json, LocalRecord record) => JobExecutionLog(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        jobId: json['job_id'] as String? ?? '',
        startedAt: DateTime.tryParse(json['started_at'] as String? ?? '') ?? record.createdAt,
        completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
        success: json['success'] as bool? ?? true,
        errorMessage: json['error_message'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, jobId, startedAt, success, version];
}

/// Scheduler subsystem health snapshot.
class SchedulerHealth extends Equatable {
  const SchedulerHealth({
    required this.isHealthy,
    required this.dueJobCount,
    required this.failedJobCount,
    required this.runningJobCount,
    required this.recentFailureCount,
    required this.checkedAt,
  });

  final bool isHealthy;
  final int dueJobCount;
  final int failedJobCount;
  final int runningJobCount;
  final int recentFailureCount;
  final DateTime checkedAt;

  @override
  List<Object?> get props => [isHealthy, dueJobCount, failedJobCount, checkedAt];
}
