import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

class RoleDefinition extends Equatable implements SyncableEntity {
  const RoleDefinition({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.description,
    this.permissions = const [],
    this.isSystem = false,
    this.deletedAt,
  });

  static const entityTypeName = 'role_definition';

  @override
  final String id;
  @override
  final String tenantId;
  final String code;
  final String name;
  final String? description;
  final List<String> permissions;
  final bool isSystem;
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
        'code': code,
        'name': name,
        'description': description,
        'permissions': permissions,
        'is_system': isSystem,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static RoleDefinition fromPayload(Map<String, dynamic> json, LocalRecord record) => RoleDefinition(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        code: json['code'] as String? ?? '',
        name: json['name'] as String? ?? record.searchName ?? '',
        description: json['description'] as String?,
        permissions: List<String>.from(json['permissions'] as List? ?? []),
        isSystem: json['is_system'] as bool? ?? false,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, code, name, version];
}

class PermissionAssignment extends Equatable implements SyncableEntity {
  const PermissionAssignment({
    required this.id,
    required this.tenantId,
    required this.subjectType,
    required this.subjectId,
    required this.permissionCode,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.grantedBy,
    this.expiresAt,
    this.deletedAt,
  });

  static const entityTypeName = 'permission_assignment';

  @override
  final String id;
  @override
  final String tenantId;
  final String subjectType;
  final String subjectId;
  final String permissionCode;
  final String? grantedBy;
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
        'subject_type': subjectType,
        'subject_id': subjectId,
        'permission_code': permissionCode,
        'granted_by': grantedBy,
        'expires_at': expiresAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static PermissionAssignment fromPayload(Map<String, dynamic> json, LocalRecord record) => PermissionAssignment(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        subjectType: json['subject_type'] as String? ?? '',
        subjectId: json['subject_id'] as String? ?? '',
        permissionCode: json['permission_code'] as String? ?? record.searchName ?? '',
        grantedBy: json['granted_by'] as String?,
        expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'] as String) : null,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, subjectType, subjectId, permissionCode, version];
}
