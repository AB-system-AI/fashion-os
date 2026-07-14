import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';

class ReturnReference extends Equatable implements SyncableEntity {
  const ReturnReference({
    required this.id,
    required this.tenantId,
    required this.storeId,
    required this.returnNumber,
    required this.saleOrderId,
    required this.employeeId,
    required this.reason,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.customerId,
    this.cashSessionId,
    this.status = ReturnStatus.pending,
    this.subtotal = 0,
    this.taxTotal = 0,
    this.refundTotal = 0,
    this.restockingFee = 0,
    this.approvedBy,
    this.completedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'sale_return';

  @override
  final String id;
  @override
  final String tenantId;
  final String storeId;
  final String returnNumber;
  final String saleOrderId;
  final String? customerId;
  final String employeeId;
  final String? cashSessionId;
  final ReturnStatus status;
  final String reason;
  final double subtotal;
  final double taxTotal;
  final double refundTotal;
  final double restockingFee;
  final String? approvedBy;
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
        'store_id': storeId,
        'return_number': returnNumber,
        'sale_order_id': saleOrderId,
        'customer_id': customerId,
        'employee_id': employeeId,
        'cash_session_id': cashSessionId,
        'status': status.value,
        'reason': reason,
        'subtotal': subtotal,
        'tax_total': taxTotal,
        'refund_total': refundTotal,
        'restocking_fee': restockingFee,
        'approved_by': approvedBy,
        'completed_at': completedAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ReturnReference fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return ReturnReference(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      storeId: json['store_id'] as String? ?? '',
      returnNumber: json['return_number'] as String? ?? '',
      saleOrderId: json['sale_order_id'] as String? ?? '',
      customerId: json['customer_id'] as String?,
      employeeId: json['employee_id'] as String? ?? '',
      cashSessionId: json['cash_session_id'] as String?,
      status: ReturnStatus.fromValue(json['status'] as String?),
      reason: json['reason'] as String? ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      taxTotal: (json['tax_total'] as num?)?.toDouble() ?? 0,
      refundTotal: (json['refund_total'] as num?)?.toDouble() ?? 0,
      restockingFee: (json['restocking_fee'] as num?)?.toDouble() ?? 0,
      approvedBy: json['approved_by'] as String?,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, returnNumber, status];
}
