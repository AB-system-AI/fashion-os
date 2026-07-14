import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/enums/inventory_enums.dart';

/// Immutable stock ledger entry — never updated, only reversed via new movement.
class StockMovement extends Equatable implements SyncableEntity {
  const StockMovement({
    required this.id,
    required this.tenantId,
    required this.warehouseId,
    required this.productId,
    required this.movementType,
    required this.quantity,
    required this.quantityAfter,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.variantId,
    this.reason = MovementReason.receipt,
    this.referenceType,
    this.referenceId,
    this.reversalOfId,
    this.notes,
    this.employeeId,
    this.deletedAt,
  });

  static const entityTypeName = 'stock_movement';

  @override
  final String id;
  @override
  final String tenantId;
  final String warehouseId;
  final String productId;
  final String? variantId;
  final MovementType movementType;
  final MovementReason reason;
  final double quantity;
  final double quantityAfter;
  final String? referenceType;
  final String? referenceId;
  final String? reversalOfId;
  final String? notes;
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

  bool get isReversal => reversalOfId != null;

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'warehouse_id': warehouseId,
        'product_id': productId,
        'variant_id': variantId,
        'movement_type': movementType.value,
        'reason': reason.value,
        'quantity': quantity,
        'quantity_after': quantityAfter,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'reversal_of_id': reversalOfId,
        'notes': notes,
        'employee_id': employeeId,
        'version': version,
      };

  factory StockMovement.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return StockMovement(
      id: record.id,
      tenantId: record.tenantId,
      warehouseId: json['warehouse_id'] as String? ?? record.storeId ?? '',
      productId: json['product_id'] as String? ?? record.searchSku ?? '',
      variantId: json['variant_id'] as String?,
      movementType: MovementType.fromValue(json['movement_type'] as String? ?? 'ADJUSTMENT'),
      reason: MovementReason.values.firstWhere(
        (e) => e.value == (json['reason'] as String? ?? 'receipt'),
        orElse: () => MovementReason.receipt,
      ),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      quantityAfter: (json['quantity_after'] as num?)?.toDouble() ?? 0,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      reversalOfId: json['reversal_of_id'] as String?,
      notes: json['notes'] as String?,
      employeeId: json['employee_id'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, movementType, quantity, createdAt];
}
