import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/system/domain/enums/system_enums.dart';

class SystemHealthSnapshot extends Equatable implements SyncableEntity {
  const SystemHealthSnapshot({
    required this.id,
    required this.tenantId,
    required this.capturedAt,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = HealthStatus.unknown,
    this.cpuPercent = 0,
    this.memoryMb = 0,
    this.diskPercent = 0,
    this.activeConnections = 0,
    this.details = const {},
    this.deletedAt,
  });

  static const entityTypeName = 'system_health_snapshot';

  @override
  final String id;
  @override
  final String tenantId;
  final DateTime capturedAt;
  final HealthStatus status;
  final double cpuPercent;
  final double memoryMb;
  final double diskPercent;
  final int activeConnections;
  final Map<String, dynamic> details;
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
        'captured_at': capturedAt.toIso8601String(),
        'status': status.value,
        'cpu_percent': cpuPercent,
        'memory_mb': memoryMb,
        'disk_percent': diskPercent,
        'active_connections': activeConnections,
        'details': details,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static SystemHealthSnapshot fromPayload(Map<String, dynamic> json, LocalRecord record) => SystemHealthSnapshot(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        capturedAt: DateTime.tryParse(json['captured_at'] as String? ?? '') ?? record.createdAt,
        status: HealthStatus.fromValue(json['status'] as String?),
        cpuPercent: (json['cpu_percent'] as num?)?.toDouble() ?? 0,
        memoryMb: (json['memory_mb'] as num?)?.toDouble() ?? 0,
        diskPercent: (json['disk_percent'] as num?)?.toDouble() ?? 0,
        activeConnections: json['active_connections'] as int? ?? 0,
        details: Map<String, dynamic>.from(json['details'] as Map? ?? {}),
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, status, capturedAt, version];
}

class ErrorLogEntry extends Equatable implements SyncableEntity {
  const ErrorLogEntry({
    required this.id,
    required this.tenantId,
    required this.message,
    required this.occurredAt,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.severity = ErrorSeverity.error,
    this.source,
    this.stackTrace,
    this.context = const {},
    this.resolved = false,
    this.deletedAt,
  });

  static const entityTypeName = 'error_log_entry';

  @override
  final String id;
  @override
  final String tenantId;
  final String message;
  final ErrorSeverity severity;
  final String? source;
  final String? stackTrace;
  final Map<String, dynamic> context;
  final DateTime occurredAt;
  final bool resolved;
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
        'message': message,
        'severity': severity.value,
        'source': source,
        'stack_trace': stackTrace,
        'context': context,
        'occurred_at': occurredAt.toIso8601String(),
        'resolved': resolved,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ErrorLogEntry fromPayload(Map<String, dynamic> json, LocalRecord record) => ErrorLogEntry(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        message: json['message'] as String? ?? record.searchName ?? '',
        severity: ErrorSeverity.fromValue(json['severity'] as String?),
        source: json['source'] as String?,
        stackTrace: json['stack_trace'] as String?,
        context: Map<String, dynamic>.from(json['context'] as Map? ?? {}),
        occurredAt: DateTime.tryParse(json['occurred_at'] as String? ?? '') ?? record.createdAt,
        resolved: json['resolved'] as bool? ?? false,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, message, severity, occurredAt];
}

class BackgroundJobStatus extends Equatable implements SyncableEntity {
  const BackgroundJobStatus({
    required this.id,
    required this.tenantId,
    required this.jobName,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = JobRunStatus.pending,
    this.lastRunAt,
    this.nextRunAt,
    this.lastError,
    this.runCount = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'background_job_status';

  @override
  final String id;
  @override
  final String tenantId;
  final String jobName;
  final JobRunStatus status;
  final DateTime? lastRunAt;
  final DateTime? nextRunAt;
  final String? lastError;
  final int runCount;
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
        'job_name': jobName,
        'status': status.value,
        'last_run_at': lastRunAt?.toIso8601String(),
        'next_run_at': nextRunAt?.toIso8601String(),
        'last_error': lastError,
        'run_count': runCount,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static BackgroundJobStatus fromPayload(Map<String, dynamic> json, LocalRecord record) => BackgroundJobStatus(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        jobName: json['job_name'] as String? ?? record.searchName ?? '',
        status: JobRunStatus.fromValue(json['status'] as String?),
        lastRunAt: json['last_run_at'] != null ? DateTime.tryParse(json['last_run_at'] as String) : null,
        nextRunAt: json['next_run_at'] != null ? DateTime.tryParse(json['next_run_at'] as String) : null,
        lastError: json['last_error'] as String?,
        runCount: json['run_count'] as int? ?? 0,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, jobName, status, version];
}

class SyncMonitorSnapshot extends Equatable implements SyncableEntity {
  const SyncMonitorSnapshot({
    required this.id,
    required this.tenantId,
    required this.capturedAt,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.pendingCount = 0,
    this.failedCount = 0,
    this.processingCount = 0,
    this.lastSyncAt,
    this.engineState = 'idle',
    this.deletedAt,
  });

  static const entityTypeName = 'sync_monitor_snapshot';

  @override
  final String id;
  @override
  final String tenantId;
  final DateTime capturedAt;
  final int pendingCount;
  final int failedCount;
  final int processingCount;
  final DateTime? lastSyncAt;
  final String engineState;
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
        'captured_at': capturedAt.toIso8601String(),
        'pending_count': pendingCount,
        'failed_count': failedCount,
        'processing_count': processingCount,
        'last_sync_at': lastSyncAt?.toIso8601String(),
        'engine_state': engineState,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static SyncMonitorSnapshot fromPayload(Map<String, dynamic> json, LocalRecord record) => SyncMonitorSnapshot(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        capturedAt: DateTime.tryParse(json['captured_at'] as String? ?? '') ?? record.createdAt,
        pendingCount: json['pending_count'] as int? ?? 0,
        failedCount: json['failed_count'] as int? ?? 0,
        processingCount: json['processing_count'] as int? ?? 0,
        lastSyncAt: json['last_sync_at'] != null ? DateTime.tryParse(json['last_sync_at'] as String) : null,
        engineState: json['engine_state'] as String? ?? 'idle',
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, capturedAt, pendingCount, failedCount];
}

class StorageUsageSnapshot extends Equatable implements SyncableEntity {
  const StorageUsageSnapshot({
    required this.id,
    required this.tenantId,
    required this.capturedAt,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.databaseMb = 0,
    this.mediaMb = 0,
    this.cacheMb = 0,
    this.totalMb = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'storage_usage_snapshot';

  @override
  final String id;
  @override
  final String tenantId;
  final DateTime capturedAt;
  final double databaseMb;
  final double mediaMb;
  final double cacheMb;
  final double totalMb;
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
        'captured_at': capturedAt.toIso8601String(),
        'database_mb': databaseMb,
        'media_mb': mediaMb,
        'cache_mb': cacheMb,
        'total_mb': totalMb,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static StorageUsageSnapshot fromPayload(Map<String, dynamic> json, LocalRecord record) => StorageUsageSnapshot(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        capturedAt: DateTime.tryParse(json['captured_at'] as String? ?? '') ?? record.createdAt,
        databaseMb: (json['database_mb'] as num?)?.toDouble() ?? 0,
        mediaMb: (json['media_mb'] as num?)?.toDouble() ?? 0,
        cacheMb: (json['cache_mb'] as num?)?.toDouble() ?? 0,
        totalMb: (json['total_mb'] as num?)?.toDouble() ?? 0,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, capturedAt, totalMb];
}
