import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

class MaterialIssue extends Equatable implements SyncableEntity {
  const MaterialIssue({
    required this.id,
    required this.tenantId,
    required this.productionOrderId,
    required this.productId,
    required this.quantity,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.warehouseId,
    this.issueDate,
    this.deletedAt,
  });

  static const entityTypeName = 'material_issue';

  @override
  final String id;
  @override
  final String tenantId;
  final String productionOrderId;
  final String productId;
  final double quantity;
  final String? warehouseId;
  final DateTime? issueDate;
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
        'product_id': productId,
        'quantity': quantity,
        'warehouse_id': warehouseId,
        'issue_date': issueDate?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static MaterialIssue fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return MaterialIssue(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      productionOrderId: json['production_order_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      warehouseId: json['warehouse_id'] as String?,
      issueDate: DateTime.tryParse(json['issue_date'] as String? ?? ''),
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, productionOrderId, productId];
}

class MaterialReturn extends Equatable implements SyncableEntity {
  const MaterialReturn({
    required this.id,
    required this.tenantId,
    required this.productionOrderId,
    required this.productId,
    required this.quantity,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.warehouseId,
    this.returnDate,
    this.deletedAt,
  });

  static const entityTypeName = 'material_return';

  @override
  final String id;
  @override
  final String tenantId;
  final String productionOrderId;
  final String productId;
  final double quantity;
  final String? warehouseId;
  final DateTime? returnDate;
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
        'product_id': productId,
        'quantity': quantity,
        'warehouse_id': warehouseId,
        'return_date': returnDate?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static MaterialReturn fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return MaterialReturn(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      productionOrderId: json['production_order_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      warehouseId: json['warehouse_id'] as String?,
      returnDate: DateTime.tryParse(json['return_date'] as String? ?? ''),
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, productionOrderId, productId];
}
