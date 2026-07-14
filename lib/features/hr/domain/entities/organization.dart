import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

class Department extends Equatable implements SyncableEntity {
  const Department({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.parentId,
    this.managerId,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'department';

  @override
  final String id;
  @override
  final String tenantId;
  final String code;
  final String name;
  final String? parentId;
  final String? managerId;
  final bool active;
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
        'parent_id': parentId,
        'manager_id': managerId,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Department fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Department(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      parentId: json['parent_id'] as String?,
      managerId: json['manager_id'] as String?,
      active: json['is_active'] as bool? ?? true,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, code];
}

class Position extends Equatable implements SyncableEntity {
  const Position({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.departmentId,
    this.defaultSalary = 0,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'position';

  @override
  final String id;
  @override
  final String tenantId;
  final String code;
  final String name;
  final String? departmentId;
  final double defaultSalary;
  final bool active;
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
        'department_id': departmentId,
        'default_salary': defaultSalary,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Position fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Position(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      departmentId: json['department_id'] as String?,
      defaultSalary: (json['default_salary'] as num?)?.toDouble() ?? 0,
      active: json['is_active'] as bool? ?? true,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, code];
}
