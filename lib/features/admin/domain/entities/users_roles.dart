import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/organization.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/enums/admin_enums.dart';

class AdminUser extends Equatable with AdminEntity {
  const AdminUser({
    required this.id,
    required this.tenantId,
    required this.email,
    required this.displayName,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.employeeId,
    this.roleIds = const [],
    this.status = AdminUserStatus.active,
    this.lastLoginAt,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_user';

  @override
  final String id;
  @override
  final String tenantId;
  final String email;
  final String displayName;
  final String? employeeId;
  final List<String> roleIds;
  final AdminUserStatus status;
  final DateTime? lastLoginAt;
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
        'email': email,
        'display_name': displayName,
        'employee_id': employeeId,
        'role_ids': roleIds,
        'status': status.value,
        if (lastLoginAt != null) 'last_login_at': lastLoginAt!.toIso8601String(),
      };

  static AdminUser fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return AdminUser(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      email: m['email'] as String? ?? '',
      displayName: m['display_name'] as String? ?? '',
      employeeId: m['employee_id'] as String?,
      roleIds: List<String>.from(m['role_ids'] as List? ?? []),
      status: AdminUserStatus.fromValue(m['status'] as String?),
      lastLoginAt: m['last_login_at'] != null ? DateTime.parse(m['last_login_at'] as String) : null,
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, email, status];
}

class RoleTemplate extends Equatable with AdminEntity {
  const RoleTemplate({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.permissionCodes,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.description,
    this.isSystem = false,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_role_template';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? description;
  final List<String> permissionCodes;
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
        ...basePayload(),
        'name': name,
        'description': description,
        'permission_codes': permissionCodes,
        'is_system': isSystem,
      };

  static RoleTemplate fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return RoleTemplate(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      name: m['name'] as String? ?? '',
      description: m['description'] as String?,
      permissionCodes: List<String>.from(m['permission_codes'] as List? ?? []),
      isSystem: m['is_system'] as bool? ?? false,
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, name, permissionCodes];
}

class UserGroup extends Equatable with AdminEntity {
  const UserGroup({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.memberIds,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.description,
    this.roleTemplateId,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_user_group';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? description;
  final List<String> memberIds;
  final String? roleTemplateId;
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
        'description': description,
        'member_ids': memberIds,
        'role_template_id': roleTemplateId,
      };

  static UserGroup fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return UserGroup(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      name: m['name'] as String? ?? '',
      description: m['description'] as String?,
      memberIds: List<String>.from(m['member_ids'] as List? ?? []),
      roleTemplateId: m['role_template_id'] as String?,
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, name];
}

class PermissionAssignmentUI extends Equatable with AdminEntity {
  const PermissionAssignmentUI({
    required this.id,
    required this.tenantId,
    required this.subjectId,
    required this.subjectType,
    required this.permissionCodes,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.deletedAt,
  });

  static const entityTypeName = 'admin_permission_assignment';

  @override
  final String id;
  @override
  final String tenantId;
  final String subjectId;
  final String subjectType;
  final List<String> permissionCodes;
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
        'subject_id': subjectId,
        'subject_type': subjectType,
        'permission_codes': permissionCodes,
      };

  static PermissionAssignmentUI fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final m = AdminEntity.mergeRecord(json, record);
    return PermissionAssignmentUI(
      id: m['id'] as String,
      tenantId: m['tenant_id'] as String,
      subjectId: m['subject_id'] as String? ?? '',
      subjectType: m['subject_type'] as String? ?? 'user',
      permissionCodes: List<String>.from(m['permission_codes'] as List? ?? []),
      version: m['version'] as int? ?? 1,
      createdAt: DateTime.parse(m['created_at'] as String),
      updatedAt: DateTime.parse(m['updated_at'] as String),
      deletedAt: m['deleted_at'] != null ? DateTime.parse(m['deleted_at'] as String) : null,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId, subjectId, permissionCodes];
}
