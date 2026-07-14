import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/enums/manufacturing_enums.dart';

class WorkCenter extends Equatable implements SyncableEntity {
  const WorkCenter({
    required this.id,
    required this.tenantId,
    required this.code,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.capacityHoursPerDay = 8,
    this.costPerHour = 0,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'work_center';

  @override
  final String id;
  @override
  final String tenantId;
  final String code;
  final String name;
  final double capacityHoursPerDay;
  final double costPerHour;
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
        'capacity_hours_per_day': capacityHoursPerDay,
        'cost_per_hour': costPerHour,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static WorkCenter fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return WorkCenter(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      capacityHoursPerDay: (json['capacity_hours_per_day'] as num?)?.toDouble() ?? 8,
      costPerHour: (json['cost_per_hour'] as num?)?.toDouble() ?? 0,
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

class Machine extends Equatable implements SyncableEntity {
  const Machine({
    required this.id,
    required this.tenantId,
    required this.workCenterId,
    required this.code,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'machine';

  @override
  final String id;
  @override
  final String tenantId;
  final String workCenterId;
  final String code;
  final String name;
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
        'work_center_id': workCenterId,
        'code': code,
        'name': name,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Machine fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Machine(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      workCenterId: json['work_center_id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
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
