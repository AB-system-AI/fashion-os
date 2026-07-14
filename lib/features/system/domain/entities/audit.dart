import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

/// Explorer-facing audit entry — maps from core [AuditEntry] or remote sync.
class SystemAuditEntry extends Equatable implements SyncableEntity {
  const SystemAuditEntry({
    required this.id,
    required this.tenantId,
    required this.action,
    required this.entityType,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.storeId,
    this.employeeId,
    this.deviceId,
    this.entityId,
    this.oldValue,
    this.newValue,
    this.metadata = const {},
    this.synced = false,
    this.deletedAt,
  });

  static const entityTypeName = 'system_audit_entry';

  @override
  final String id;
  @override
  final String tenantId;
  final String? storeId;
  final String? employeeId;
  final String? deviceId;
  final String action;
  final String entityType;
  final String? entityId;
  final String? oldValue;
  final String? newValue;
  final Map<String, dynamic> metadata;
  final bool synced;
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

  factory SystemAuditEntry.fromAuditEntry(AuditEntry entry) => SystemAuditEntry(
        id: entry.id,
        tenantId: entry.tenantId ?? '',
        storeId: entry.storeId,
        employeeId: entry.employeeId,
        deviceId: entry.deviceId,
        action: entry.action.value,
        entityType: entry.entityType,
        entityId: entry.entityId,
        oldValue: entry.oldValue,
        newValue: entry.newValue,
        metadata: entry.metadata,
        synced: entry.synced,
        version: 1,
        createdAt: entry.createdAt,
        updatedAt: entry.createdAt,
        syncStatus: entry.synced ? LocalSyncStatus.synced : LocalSyncStatus.pending,
        isDirty: !entry.synced,
      );

  AuditAction get auditAction => AuditAction.values.firstWhere(
        (a) => a.value == action,
        orElse: () => AuditAction.update,
      );

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'store_id': storeId,
        'employee_id': employeeId,
        'device_id': deviceId,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'old_value': oldValue,
        'new_value': newValue,
        'metadata': metadata,
        'synced': synced,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static SystemAuditEntry fromPayload(Map<String, dynamic> json, LocalRecord record) => SystemAuditEntry(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        storeId: json['store_id'] as String?,
        employeeId: json['employee_id'] as String?,
        deviceId: json['device_id'] as String?,
        action: json['action'] as String? ?? 'update',
        entityType: json['entity_type'] as String? ?? record.searchName ?? '',
        entityId: json['entity_id'] as String?,
        oldValue: json['old_value'] as String?,
        newValue: json['new_value'] as String?,
        metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
        synced: json['synced'] as bool? ?? false,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, action, entityType, entityId, createdAt];
}
