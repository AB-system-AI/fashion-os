import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/enums/manufacturing_enums.dart';

class CapacityPlan extends Equatable implements SyncableEntity {
  const CapacityPlan({
    required this.id,
    required this.tenantId,
    required this.workCenterId,
    required this.planDate,
    required this.availableHours,
    required this.scheduledHours,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = CapacityStatus.available,
    this.deletedAt,
  });

  static const entityTypeName = 'capacity_plan';

  @override
  final String id;
  @override
  final String tenantId;
  final String workCenterId;
  final DateTime planDate;
  final double availableHours;
  final double scheduledHours;
  final CapacityStatus status;
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
        'plan_date': planDate.toIso8601String().split('T').first,
        'available_hours': availableHours,
        'scheduled_hours': scheduledHours,
        'status': status.value,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static CapacityPlan fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return CapacityPlan(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      workCenterId: json['work_center_id'] as String? ?? '',
      planDate: DateTime.tryParse(json['plan_date'] as String? ?? '') ?? record.createdAt,
      availableHours: (json['available_hours'] as num?)?.toDouble() ?? 0,
      scheduledHours: (json['scheduled_hours'] as num?)?.toDouble() ?? 0,
      status: CapacityStatus.fromValue(json['status'] as String?),
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, workCenterId, planDate];
}

class ProductionSchedule extends Equatable implements SyncableEntity {
  const ProductionSchedule({
    required this.id,
    required this.tenantId,
    required this.productionOrderId,
    required this.scheduledStart,
    required this.scheduledEnd,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.workCenterId,
    this.deletedAt,
  });

  static const entityTypeName = 'production_schedule';

  @override
  final String id;
  @override
  final String tenantId;
  final String productionOrderId;
  final String? workCenterId;
  final DateTime scheduledStart;
  final DateTime scheduledEnd;
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
        'production_order_id': productionOrderId,
        'work_center_id': workCenterId,
        'scheduled_start': scheduledStart.toIso8601String(),
        'scheduled_end': scheduledEnd.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ProductionSchedule fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return ProductionSchedule(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      productionOrderId: json['production_order_id'] as String? ?? '',
      workCenterId: json['work_center_id'] as String?,
      scheduledStart: DateTime.tryParse(json['scheduled_start'] as String? ?? '') ?? record.createdAt,
      scheduledEnd: DateTime.tryParse(json['scheduled_end'] as String? ?? '') ?? record.createdAt,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, productionOrderId];
}

class ManufacturingSettings extends Equatable implements SyncableEntity {
  const ManufacturingSettings({
    required this.id,
    required this.tenantId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.planningMethod = PlanningMethod.mrp,
    this.defaultScrapPercent = 0,
    this.autoBackflush = false,
    this.deletedAt,
  });

  static const entityTypeName = 'manufacturing_settings';

  @override
  final String id;
  @override
  final String tenantId;
  final PlanningMethod planningMethod;
  final double defaultScrapPercent;
  final bool autoBackflush;
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
        'planning_method': planningMethod.value,
        'default_scrap_percent': defaultScrapPercent,
        'auto_backflush': autoBackflush,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ManufacturingSettings fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return ManufacturingSettings(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      planningMethod: PlanningMethod.fromValue(json['planning_method'] as String?),
      defaultScrapPercent: (json['default_scrap_percent'] as num?)?.toDouble() ?? 0,
      autoBackflush: json['auto_backflush'] as bool? ?? false,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, tenantId];
}
