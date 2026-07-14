import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/enums/manufacturing_enums.dart';

class QualityInspection extends Equatable implements SyncableEntity {
  const QualityInspection({
    required this.id,
    required this.tenantId,
    required this.productionOrderId,
    required this.inspectedQty,
    required this.result,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.inspectorId,
    this.passedQty = 0,
    this.failedQty = 0,
    this.notes,
    this.deletedAt,
  });

  static const entityTypeName = 'quality_inspection';

  @override
  final String id;
  @override
  final String tenantId;
  final String productionOrderId;
  final String? inspectorId;
  final double inspectedQty;
  final double passedQty;
  final double failedQty;
  final QualityResult result;
  final String? notes;
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
        'inspector_id': inspectorId,
        'inspected_qty': inspectedQty,
        'passed_qty': passedQty,
        'failed_qty': failedQty,
        'result': result.value,
        'notes': notes,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static QualityInspection fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return QualityInspection(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      productionOrderId: json['production_order_id'] as String? ?? '',
      inspectorId: json['inspector_id'] as String?,
      inspectedQty: (json['inspected_qty'] as num?)?.toDouble() ?? 0,
      passedQty: (json['passed_qty'] as num?)?.toDouble() ?? 0,
      failedQty: (json['failed_qty'] as num?)?.toDouble() ?? 0,
      result: QualityResult.fromValue(json['result'] as String?),
      notes: json['notes'] as String?,
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

class MaintenanceRequest extends Equatable implements SyncableEntity {
  const MaintenanceRequest({
    required this.id,
    required this.tenantId,
    required this.machineId,
    required this.title,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.description,
    this.scheduledDate,
    this.completed = false,
    this.deletedAt,
  });

  static const entityTypeName = 'maintenance_request';

  @override
  final String id;
  @override
  final String tenantId;
  final String machineId;
  final String title;
  final String? description;
  final DateTime? scheduledDate;
  final bool completed;
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
        'machine_id': machineId,
        'title': title,
        'description': description,
        'scheduled_date': scheduledDate?.toIso8601String(),
        'is_completed': completed,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static MaintenanceRequest fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return MaintenanceRequest(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      machineId: json['machine_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      scheduledDate: DateTime.tryParse(json['scheduled_date'] as String? ?? ''),
      completed: json['is_completed'] as bool? ?? false,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, machineId];
}
