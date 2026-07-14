import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/enums/manufacturing_enums.dart';

class WorkOrder extends Equatable implements SyncableEntity {
  const WorkOrder({
    required this.id,
    required this.tenantId,
    required this.workOrderNumber,
    required this.productionOrderId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.workCenterId,
    this.employeeId,
    this.status = WorkOrderStatus.draft,
    this.plannedHours = 0,
    this.actualHours = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'work_order';

  @override
  final String id;
  @override
  final String tenantId;
  final String workOrderNumber;
  final String productionOrderId;
  final String? workCenterId;
  final String? employeeId;
  final WorkOrderStatus status;
  final double plannedHours;
  final double actualHours;
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

  WorkOrder copyWith({
    WorkOrderStatus? status,
    String? employeeId,
    double? actualHours,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return WorkOrder(
      id: id,
      tenantId: tenantId,
      workOrderNumber: workOrderNumber,
      productionOrderId: productionOrderId,
      workCenterId: workCenterId,
      employeeId: employeeId ?? this.employeeId,
      status: status ?? this.status,
      plannedHours: plannedHours,
      actualHours: actualHours ?? this.actualHours,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'work_order_number': workOrderNumber,
        'production_order_id': productionOrderId,
        'work_center_id': workCenterId,
        'employee_id': employeeId,
        'status': status.value,
        'planned_hours': plannedHours,
        'actual_hours': actualHours,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static WorkOrder fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return WorkOrder(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      workOrderNumber: json['work_order_number'] as String? ?? '',
      productionOrderId: json['production_order_id'] as String? ?? '',
      workCenterId: json['work_center_id'] as String?,
      employeeId: json['employee_id'] as String?,
      status: WorkOrderStatus.fromValue(json['status'] as String?),
      plannedHours: (json['planned_hours'] as num?)?.toDouble() ?? 0,
      actualHours: (json['actual_hours'] as num?)?.toDouble() ?? 0,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, workOrderNumber];
}

class Operation extends Equatable implements SyncableEntity {
  const Operation({
    required this.id,
    required this.tenantId,
    required this.workOrderId,
    required this.name,
    required this.sequence,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = OperationStatus.pending,
    this.setupMinutes = 0,
    this.runMinutesPerUnit = 0,
    this.deletedAt,
  });

  static const entityTypeName = 'operation';

  @override
  final String id;
  @override
  final String tenantId;
  final String workOrderId;
  final String name;
  final int sequence;
  final OperationStatus status;
  final int setupMinutes;
  final double runMinutesPerUnit;
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
        'work_order_id': workOrderId,
        'name': name,
        'sequence': sequence,
        'status': status.value,
        'setup_minutes': setupMinutes,
        'run_minutes_per_unit': runMinutesPerUnit,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Operation fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Operation(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      workOrderId: json['work_order_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      sequence: (json['sequence'] as num?)?.toInt() ?? 1,
      status: OperationStatus.fromValue(json['status'] as String?),
      setupMinutes: (json['setup_minutes'] as num?)?.toInt() ?? 0,
      runMinutesPerUnit: (json['run_minutes_per_unit'] as num?)?.toDouble() ?? 0,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, workOrderId, sequence];
}
