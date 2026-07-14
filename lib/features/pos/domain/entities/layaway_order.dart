import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';

class LayawayPayment extends Equatable {
  const LayawayPayment({
    required this.id,
    required this.amount,
    this.processedAt,
    this.paymentMethodId,
  });

  final String id;
  final double amount;
  final DateTime? processedAt;
  final String? paymentMethodId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'processed_at': processedAt?.toIso8601String(),
        'payment_method_id': paymentMethodId,
      };

  factory LayawayPayment.fromJson(Map<String, dynamic> json) {
    return LayawayPayment(
      id: json['id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      processedAt: json['processed_at'] != null ? DateTime.tryParse(json['processed_at'] as String) : null,
      paymentMethodId: json['payment_method_id'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, amount];
}

class LayawayOrder extends Equatable implements SyncableEntity {
  const LayawayOrder({
    required this.id,
    required this.tenantId,
    required this.storeId,
    required this.layawayNumber,
    required this.saleOrderId,
    required this.customerId,
    required this.totalAmount,
    required this.depositAmount,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.payments = const [],
    this.status = LayawayStatus.active,
    this.pickupDueDate,
    this.completedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'layaway_order';

  @override
  final String id;
  @override
  final String tenantId;
  final String storeId;
  final String layawayNumber;
  final String saleOrderId;
  final String customerId;
  final double totalAmount;
  final double depositAmount;
  final List<LayawayPayment> payments;
  final LayawayStatus status;
  final DateTime? pickupDueDate;
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

  double get paidAmount => depositAmount + payments.fold(0.0, (s, p) => s + p.amount);
  double get remainingBalance => (totalAmount - paidAmount).clamp(0, double.infinity);

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'store_id': storeId,
        'layaway_number': layawayNumber,
        'sale_order_id': saleOrderId,
        'customer_id': customerId,
        'total_amount': totalAmount,
        'deposit_amount': depositAmount,
        'payments': payments.map((p) => p.toJson()).toList(),
        'status': status.value,
        'pickup_due_date': pickupDueDate?.toIso8601String(),
        'completed_at': completedAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static LayawayOrder fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final paymentsJson = json['payments'] as List? ?? [];
    return LayawayOrder(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      storeId: json['store_id'] as String? ?? '',
      layawayNumber: json['layaway_number'] as String? ?? '',
      saleOrderId: json['sale_order_id'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      depositAmount: (json['deposit_amount'] as num?)?.toDouble() ?? 0,
      payments: paymentsJson.map((e) => LayawayPayment.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      status: LayawayStatus.fromValue(json['status'] as String?),
      pickupDueDate: json['pickup_due_date'] != null ? DateTime.tryParse(json['pickup_due_date'] as String) : null,
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
  List<Object?> get props => [id, layawayNumber, status];
}
