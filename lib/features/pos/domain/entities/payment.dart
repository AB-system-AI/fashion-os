import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';

class Payment extends Equatable implements SyncableEntity {
  const Payment({
    required this.id,
    required this.tenantId,
    required this.saleOrderId,
    required this.paymentMethodId,
    required this.methodKind,
    required this.amount,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = PaymentStatus.completed,
    this.currency = 'USD',
    this.referenceNumber,
    this.cardLastFour,
    this.processedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'sale_payment';

  @override
  final String id;
  @override
  final String tenantId;
  final String saleOrderId;
  final String paymentMethodId;
  final PaymentMethodKind methodKind;
  final PaymentStatus status;
  final double amount;
  final String currency;
  final String? referenceNumber;
  final String? cardLastFour;
  final DateTime? processedAt;
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
        'sale_order_id': saleOrderId,
        'payment_method_id': paymentMethodId,
        'method_kind': methodKind.value,
        'status': status.value,
        'amount': amount,
        'currency': currency,
        'reference_number': referenceNumber,
        'card_last_four': cardLastFour,
        'processed_at': processedAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static Payment fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Payment(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      saleOrderId: json['sale_order_id'] as String? ?? '',
      paymentMethodId: json['payment_method_id'] as String? ?? '',
      methodKind: PaymentMethodKind.fromValue(json['method_kind'] as String?),
      status: PaymentStatus.fromValue(json['status'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      referenceNumber: json['reference_number'] as String?,
      cardLastFour: json['card_last_four'] as String?,
      processedAt: json['processed_at'] != null ? DateTime.tryParse(json['processed_at'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  Payment copyWith({
    PaymentStatus? status,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return Payment(
      id: id,
      tenantId: tenantId,
      saleOrderId: saleOrderId,
      paymentMethodId: paymentMethodId,
      methodKind: methodKind,
      status: status ?? this.status,
      amount: amount,
      currency: currency,
      referenceNumber: referenceNumber,
      cardLastFour: cardLastFour,
      processedAt: processedAt,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, saleOrderId, amount, status];
}
