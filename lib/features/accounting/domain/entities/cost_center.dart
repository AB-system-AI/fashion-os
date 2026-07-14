import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

class CostCenter extends Equatable implements SyncableEntity {
  const CostCenter({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.storeId,
    this.parentId,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'cost_center';

  @override
  final String id;
  @override
  final String tenantId;
  final String? storeId;
  final String code;
  final String name;
  final String? parentId;
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
        'store_id': storeId,
        'code': code,
        'name': name,
        'parent_id': parentId,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static CostCenter fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return CostCenter(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      storeId: json['store_id'] as String?,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      parentId: json['parent_id'] as String?,
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
