import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/system/domain/enums/system_enums.dart';

class SecuritySession extends Equatable implements SyncableEntity {
  const SecuritySession({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.deviceId,
    this.ipAddress,
    this.userAgent,
    this.status = SessionStatus.active,
    this.lastActivityAt,
    this.expiresAt,
    this.deletedAt,
  });

  static const entityTypeName = 'security_session';

  @override
  final String id;
  @override
  final String tenantId;
  final String userId;
  final String? deviceId;
  final String? ipAddress;
  final String? userAgent;
  final SessionStatus status;
  final DateTime? lastActivityAt;
  final DateTime? expiresAt;
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
        'user_id': userId,
        'device_id': deviceId,
        'ip_address': ipAddress,
        'user_agent': userAgent,
        'status': status.value,
        'last_activity_at': lastActivityAt?.toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static SecuritySession fromPayload(Map<String, dynamic> json, LocalRecord record) => SecuritySession(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        userId: json['user_id'] as String? ?? '',
        deviceId: json['device_id'] as String?,
        ipAddress: json['ip_address'] as String?,
        userAgent: json['user_agent'] as String?,
        status: SessionStatus.fromValue(json['status'] as String?),
        lastActivityAt: json['last_activity_at'] != null ? DateTime.tryParse(json['last_activity_at'] as String) : null,
        expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'] as String) : null,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, userId, status, lastActivityAt];
}

class DeviceRegistration extends Equatable implements SyncableEntity {
  const DeviceRegistration({
    required this.id,
    required this.tenantId,
    required this.deviceName,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.platform,
    this.osVersion,
    this.appVersion,
    this.trustLevel = DeviceTrustLevel.unknown,
    this.lastSeenAt,
    this.registeredBy,
    this.deletedAt,
  });

  static const entityTypeName = 'device_registration';

  @override
  final String id;
  @override
  final String tenantId;
  final String deviceName;
  final String? platform;
  final String? osVersion;
  final String? appVersion;
  final DeviceTrustLevel trustLevel;
  final DateTime? lastSeenAt;
  final String? registeredBy;
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
        'device_name': deviceName,
        'platform': platform,
        'os_version': osVersion,
        'app_version': appVersion,
        'trust_level': trustLevel.value,
        'last_seen_at': lastSeenAt?.toIso8601String(),
        'registered_by': registeredBy,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static DeviceRegistration fromPayload(Map<String, dynamic> json, LocalRecord record) => DeviceRegistration(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        deviceName: json['device_name'] as String? ?? record.searchName ?? '',
        platform: json['platform'] as String?,
        osVersion: json['os_version'] as String?,
        appVersion: json['app_version'] as String?,
        trustLevel: DeviceTrustLevel.fromValue(json['trust_level'] as String?),
        lastSeenAt: json['last_seen_at'] != null ? DateTime.tryParse(json['last_seen_at'] as String) : null,
        registeredBy: json['registered_by'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, deviceName, trustLevel, lastSeenAt];
}

class LoginHistoryEntry extends Equatable implements SyncableEntity {
  const LoginHistoryEntry({
    required this.id,
    required this.tenantId,
    required this.userId,
    required this.occurredAt,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.success = true,
    this.ipAddress,
    this.deviceId,
    this.failureReason,
    this.deletedAt,
  });

  static const entityTypeName = 'login_history_entry';

  @override
  final String id;
  @override
  final String tenantId;
  final String userId;
  final bool success;
  final String? ipAddress;
  final String? deviceId;
  final String? failureReason;
  final DateTime occurredAt;
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
        'user_id': userId,
        'success': success,
        'ip_address': ipAddress,
        'device_id': deviceId,
        'failure_reason': failureReason,
        'occurred_at': occurredAt.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static LoginHistoryEntry fromPayload(Map<String, dynamic> json, LocalRecord record) => LoginHistoryEntry(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        userId: json['user_id'] as String? ?? '',
        success: json['success'] as bool? ?? true,
        ipAddress: json['ip_address'] as String?,
        deviceId: json['device_id'] as String?,
        failureReason: json['failure_reason'] as String?,
        occurredAt: DateTime.tryParse(json['occurred_at'] as String? ?? '') ?? record.createdAt,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, userId, success, occurredAt];
}
