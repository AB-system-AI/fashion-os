import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/enums/sales_enums.dart';

class CustomerOrderTimeline extends Equatable implements SyncableEntity {
  const CustomerOrderTimeline({
    required this.id,
    required this.tenantId,
    required this.customerId,
    required this.eventType,
    required this.title,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.referenceType,
    this.referenceId,
    this.description,
    this.employeeId,
    this.deletedAt,
  });

  static const entityTypeName = 'customer_order_timeline';

  @override
  final String id;
  @override
  final String tenantId;
  final String customerId;
  final TimelineEventType eventType;
  final String title;
  final String? description;
  final String? referenceType;
  final String? referenceId;
  final String? employeeId;
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
        'customer_id': customerId,
        'event_type': eventType.value,
        'title': title,
        'description': description,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'employee_id': employeeId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static CustomerOrderTimeline fromPayload(Map<String, dynamic> json, LocalRecord record) => CustomerOrderTimeline(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        customerId: json['customer_id'] as String? ?? '',
        eventType: TimelineEventType.fromValue(json['event_type'] as String?),
        title: json['title'] as String? ?? '',
        description: json['description'] as String?,
        referenceType: json['reference_type'] as String?,
        referenceId: json['reference_id'] as String?,
        employeeId: json['employee_id'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, customerId, eventType, version];
}

class SalesSettings extends Equatable implements SyncableEntity {
  const SalesSettings({
    required this.id,
    required this.tenantId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.defaultWarehouseId,
    this.approvalThreshold = 0,
    this.quotationValidityDays = 30,
    this.autoReserveOnApprove = true,
    this.deletedAt,
  });

  static const entityTypeName = 'sales_settings';

  @override
  final String id;
  @override
  final String tenantId;
  final String? defaultWarehouseId;
  final double approvalThreshold;
  final int quotationValidityDays;
  final bool autoReserveOnApprove;
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
        'default_warehouse_id': defaultWarehouseId,
        'approval_threshold': approvalThreshold,
        'quotation_validity_days': quotationValidityDays,
        'auto_reserve_on_approve': autoReserveOnApprove,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static SalesSettings fromPayload(Map<String, dynamic> json, LocalRecord record) => SalesSettings(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        defaultWarehouseId: json['default_warehouse_id'] as String?,
        approvalThreshold: (json['approval_threshold'] as num?)?.toDouble() ?? 0,
        quotationValidityDays: json['quotation_validity_days'] as int? ?? 30,
        autoReserveOnApprove: json['auto_reserve_on_approve'] as bool? ?? true,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, tenantId, version];
}
