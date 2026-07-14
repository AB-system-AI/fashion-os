import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/enums/assets_enums.dart';

class MaintenanceRequest extends Equatable implements SyncableEntity {
  const MaintenanceRequest({
    required this.id,
    required this.tenantId,
    required this.assetId,
    required this.title,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.description,
    this.status = MaintenanceRequestStatus.open,
    this.priority = 1,
    this.scheduleType = MaintenanceScheduleType.corrective,
    this.requestedBy,
    this.assignedTo,
    this.completedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'maintenance_request';

  @override
  final String id;
  @override
  final String tenantId;
  final String assetId;
  final String title;
  final String? description;
  final MaintenanceRequestStatus status;
  final int priority;
  final MaintenanceScheduleType scheduleType;
  final String? requestedBy;
  final String? assignedTo;
  final DateTime? completedAt;
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

  MaintenanceRequest copyWith({
    MaintenanceRequestStatus? status,
    String? assignedTo,
    DateTime? completedAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) =>
      MaintenanceRequest(
        id: id,
        tenantId: tenantId,
        assetId: assetId,
        title: title,
        description: description,
        status: status ?? this.status,
        priority: priority,
        scheduleType: scheduleType,
        requestedBy: requestedBy,
        assignedTo: assignedTo ?? this.assignedTo,
        completedAt: completedAt ?? this.completedAt,
        version: version ?? this.version,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDirty: isDirty ?? this.isDirty,
      );

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'asset_id': assetId,
        'title': title,
        'description': description,
        'status': status.value,
        'priority': priority,
        'schedule_type': scheduleType.value,
        'requested_by': requestedBy,
        'assigned_to': assignedTo,
        'completed_at': completedAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static MaintenanceRequest fromPayload(Map<String, dynamic> json, LocalRecord record) => MaintenanceRequest(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        assetId: json['asset_id'] as String? ?? '',
        title: json['title'] as String? ?? record.searchName ?? '',
        description: json['description'] as String?,
        status: MaintenanceRequestStatus.fromValue(json['status'] as String?),
        priority: json['priority'] as int? ?? 1,
        scheduleType: MaintenanceScheduleType.fromValue(json['schedule_type'] as String?),
        requestedBy: json['requested_by'] as String?,
        assignedTo: json['assigned_to'] as String?,
        completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, assetId, title, status];
}

class MaintenanceSchedule extends Equatable implements SyncableEntity {
  const MaintenanceSchedule({
    required this.id,
    required this.tenantId,
    required this.assetId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.scheduleType = MaintenanceScheduleType.preventive,
    this.intervalDays = 90,
    this.nextDueAt,
    this.lastCompletedAt,
    this.isActive = true,
    this.deletedAt,
  });

  static const entityTypeName = 'maintenance_schedule';

  @override
  final String id;
  @override
  final String tenantId;
  final String assetId;
  final String name;
  final MaintenanceScheduleType scheduleType;
  final int intervalDays;
  final DateTime? nextDueAt;
  final DateTime? lastCompletedAt;
  final bool isActive;
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
        'asset_id': assetId,
        'name': name,
        'schedule_type': scheduleType.value,
        'interval_days': intervalDays,
        'next_due_at': nextDueAt?.toIso8601String(),
        'last_completed_at': lastCompletedAt?.toIso8601String(),
        'is_active': isActive,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static MaintenanceSchedule fromPayload(Map<String, dynamic> json, LocalRecord record) => MaintenanceSchedule(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        assetId: json['asset_id'] as String? ?? '',
        name: json['name'] as String? ?? record.searchName ?? '',
        scheduleType: MaintenanceScheduleType.fromValue(json['schedule_type'] as String?),
        intervalDays: json['interval_days'] as int? ?? 90,
        nextDueAt: json['next_due_at'] != null ? DateTime.tryParse(json['next_due_at'] as String) : null,
        lastCompletedAt: json['last_completed_at'] != null ? DateTime.tryParse(json['last_completed_at'] as String) : null,
        isActive: json['is_active'] as bool? ?? true,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, assetId, name, nextDueAt];
}

class MaintenanceTask extends Equatable implements SyncableEntity {
  const MaintenanceTask({
    required this.id,
    required this.tenantId,
    required this.requestId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.description,
    this.isCompleted = false,
    this.completedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'maintenance_task';

  @override
  final String id;
  @override
  final String tenantId;
  final String requestId;
  final String name;
  final String? description;
  final bool isCompleted;
  final DateTime? completedAt;
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
        'request_id': requestId,
        'name': name,
        'description': description,
        'is_completed': isCompleted,
        'completed_at': completedAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static MaintenanceTask fromPayload(Map<String, dynamic> json, LocalRecord record) => MaintenanceTask(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        requestId: json['request_id'] as String? ?? '',
        name: json['name'] as String? ?? record.searchName ?? '',
        description: json['description'] as String?,
        isCompleted: json['is_completed'] as bool? ?? false,
        completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, requestId, name, isCompleted];
}

class MaintenanceCost extends Equatable implements SyncableEntity {
  const MaintenanceCost({
    required this.id,
    required this.tenantId,
    required this.requestId,
    required this.amount,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.costType = 'labor',
    this.description,
    this.vendorId,
    this.deletedAt,
  });

  static const entityTypeName = 'maintenance_cost';

  @override
  final String id;
  @override
  final String tenantId;
  final String requestId;
  final String costType;
  final double amount;
  final String? description;
  final String? vendorId;
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
        'request_id': requestId,
        'cost_type': costType,
        'amount': amount,
        'description': description,
        'vendor_id': vendorId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static MaintenanceCost fromPayload(Map<String, dynamic> json, LocalRecord record) => MaintenanceCost(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        requestId: json['request_id'] as String? ?? '',
        costType: json['cost_type'] as String? ?? 'labor',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        description: json['description'] as String?,
        vendorId: json['vendor_id'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, requestId, amount];
}
