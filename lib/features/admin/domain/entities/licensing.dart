import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/organization.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/enums/admin_enums.dart';

class LicenseRecord extends Equatable with AdminEntity {
  const LicenseRecord({
    required this.id,
    required this.tenantId,
    required this.planId,
    required this.status,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.expiresAt,
    this.seats = 10,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_license_record';

  @override
  final String id;
  @override
  final String tenantId;
  final String planId;
  final LicenseStatus status;
  final DateTime? expiresAt;
  final int seats;
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
        ...basePayload(),
        'plan_id': planId,
        'status': status.value,
        if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
        'seats': seats,
      };

  static LicenseRecord fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return LicenseRecord(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      planId: m['plan_id'] as String? ?? '',
      status: LicenseStatus.fromValue(m['status'] as String?),
      expiresAt: m['expires_at'] != null ? DateTime.parse(m['expires_at'] as String) : null,
      seats: m['seats'] as int? ?? 10,
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, planId, status];
}

class SubscriptionPlan extends Equatable with AdminEntity {
  const SubscriptionPlan({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.tier,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.maxUsers = 10,
    this.maxStorageMb = 1024,
    this.maxApiCallsDaily = 10000,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_subscription_plan';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final SubscriptionTier tier;
  final int maxUsers;
  final int maxStorageMb;
  final int maxApiCallsDaily;
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
        ...basePayload(),
        'name': name,
        'tier': tier.value,
        'max_users': maxUsers,
        'max_storage_mb': maxStorageMb,
        'max_api_calls_daily': maxApiCallsDaily,
      };

  static SubscriptionPlan fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return SubscriptionPlan(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      name: m['name'] as String? ?? '',
      tier: SubscriptionTier.fromValue(m['tier'] as String?),
      maxUsers: m['max_users'] as int? ?? 10,
      maxStorageMb: m['max_storage_mb'] as int? ?? 1024,
      maxApiCallsDaily: m['max_api_calls_daily'] as int? ?? 10000,
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, name, tier];
}

class UsageSnapshot extends Equatable with AdminEntity {
  const UsageSnapshot({
    required this.id,
    required this.tenantId,
    required this.capturedAt,
    required this.activeUsers,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.storageUsedMb = 0,
    this.apiCalls = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_usage_snapshot';

  @override
  final String id;
  @override
  final String tenantId;
  final DateTime capturedAt;
  final int activeUsers;
  final double storageUsedMb;
  final int apiCalls;
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
        ...basePayload(),
        'captured_at': capturedAt.toIso8601String(),
        'active_users': activeUsers,
        'storage_used_mb': storageUsedMb,
        'api_calls': apiCalls,
      };

  static UsageSnapshot fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return UsageSnapshot(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      capturedAt: DateTime.parse(m['captured_at'] as String? ?? m['created_at'] as String),
      activeUsers: m['active_users'] as int? ?? 0,
      storageUsedMb: (m['storage_used_mb'] as num?)?.toDouble() ?? 0,
      apiCalls: m['api_calls'] as int? ?? 0,
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, capturedAt];
}

class StorageUsage extends Equatable with AdminEntity {
  const StorageUsage({
    required this.id,
    required this.tenantId,
    required this.usedMb,
    required this.limitMb,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.bucket,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_storage_usage';

  @override
  final String id;
  @override
  final String tenantId;
  final String? bucket;
  final double usedMb;
  final double limitMb;
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

  double get utilizationPercent => limitMb > 0 ? (usedMb / limitMb) * 100 : 0;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        ...basePayload(),
        'bucket': bucket,
        'used_mb': usedMb,
        'limit_mb': limitMb,
      };

  static StorageUsage fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return StorageUsage(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      bucket: m['bucket'] as String?,
      usedMb: (m['used_mb'] as num?)?.toDouble() ?? 0,
      limitMb: (m['limit_mb'] as num?)?.toDouble() ?? 0,
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, bucket, usedMb];
}

class ApiUsage extends Equatable with AdminEntity {
  const ApiUsage({
    required this.id,
    required this.tenantId,
    required this.endpoint,
    required this.callCount,
    required this.periodStart,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.periodEnd,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_api_usage';

  @override
  final String id;
  @override
  final String tenantId;
  final String endpoint;
  final int callCount;
  final DateTime periodStart;
  final DateTime? periodEnd;
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
        ...basePayload(),
        'endpoint': endpoint,
        'call_count': callCount,
        'period_start': periodStart.toIso8601String(),
        if (periodEnd != null) 'period_end': periodEnd!.toIso8601String(),
      };

  static ApiUsage fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return ApiUsage(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      endpoint: m['endpoint'] as String? ?? '',
      callCount: m['call_count'] as int? ?? 0,
      periodStart: DateTime.parse(m['period_start'] as String? ?? m['created_at'] as String),
      periodEnd: m['period_end'] != null ? DateTime.parse(m['period_end'] as String) : null,
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, endpoint, callCount];
}
