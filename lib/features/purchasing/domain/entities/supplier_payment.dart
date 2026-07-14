import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/enums/purchasing_enums.dart';

class SupplierPayment extends Equatable implements SyncableEntity {
  const SupplierPayment({
    required this.id,
    required this.tenantId,
    required this.supplierId,
    required this.amount,
    required this.type,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.currency = 'USD',
    this.reference,
    this.notes,
    this.purchaseOrderId,
    this.paidAt,
    this.deletedAt,
  });

  static const entityTypeName = 'supplier_payment';

  @override
  final String id;
  @override
  final String tenantId;
  final String supplierId;
  final String? purchaseOrderId;
  final double amount;
  final String currency;
  final SupplierPaymentType type;
  final String? reference;
  final String? notes;
  final DateTime? paidAt;
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
        'supplier_id': supplierId,
        'purchase_order_id': purchaseOrderId,
        'amount': amount,
        'currency': currency,
        'type': type.value,
        'reference': reference,
        'notes': notes,
        'paid_at': paidAt?.toIso8601String(),
        'version': version,
      };

  factory SupplierPayment.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return SupplierPayment(
      id: record.id,
      tenantId: record.tenantId,
      supplierId: json['supplier_id'] as String? ?? '',
      purchaseOrderId: json['purchase_order_id'] as String?,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      type: SupplierPaymentType.fromValue(json['type'] as String?),
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, supplierId, amount, type];
}

class SupplierStatementEntry extends Equatable {
  const SupplierStatementEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.occurredAt,
    this.reference,
    this.description,
  });

  final String id;
  final SupplierTransactionType type;
  final double amount;
  final DateTime occurredAt;
  final String? reference;
  final String? description;

  @override
  List<Object?> get props => [id, type, amount];
}

class SupplierStatement extends Equatable implements SyncableEntity {
  const SupplierStatement({
    required this.id,
    required this.tenantId,
    required this.supplierId,
    required this.entries,
    required this.openingBalance,
    required this.closingBalance,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.periodStart,
    this.periodEnd,
    this.deletedAt,
  });

  static const entityTypeName = 'supplier_statement';

  @override
  final String id;
  @override
  final String tenantId;
  final String supplierId;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final double openingBalance;
  final double closingBalance;
  final List<SupplierStatementEntry> entries;
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
        'supplier_id': supplierId,
        'period_start': periodStart?.toIso8601String(),
        'period_end': periodEnd?.toIso8601String(),
        'opening_balance': openingBalance,
        'closing_balance': closingBalance,
        'entries': entries
            .map(
              (e) => {
                'id': e.id,
                'type': e.type.value,
                'amount': e.amount,
                'occurred_at': e.occurredAt.toIso8601String(),
                'reference': e.reference,
                'description': e.description,
              },
            )
            .toList(),
        'version': version,
      };

  factory SupplierStatement.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final rawEntries = json['entries'] as List<dynamic>? ?? const [];
    return SupplierStatement(
      id: record.id,
      tenantId: record.tenantId,
      supplierId: json['supplier_id'] as String? ?? '',
      periodStart: json['period_start'] != null ? DateTime.tryParse(json['period_start'] as String) : null,
      periodEnd: json['period_end'] != null ? DateTime.tryParse(json['period_end'] as String) : null,
      openingBalance: (json['opening_balance'] as num?)?.toDouble() ?? 0,
      closingBalance: (json['closing_balance'] as num?)?.toDouble() ?? 0,
      entries: rawEntries
          .map(
            (e) {
              final m = Map<String, dynamic>.from(e as Map);
              return SupplierStatementEntry(
                id: m['id'] as String? ?? '',
                type: SupplierTransactionType.values.firstWhere(
                  (t) => t.value == m['type'],
                  orElse: () => SupplierTransactionType.purchase,
                ),
                amount: (m['amount'] as num?)?.toDouble() ?? 0,
                occurredAt: DateTime.tryParse(m['occurred_at'] as String? ?? '') ?? record.createdAt,
                reference: m['reference'] as String?,
                description: m['description'] as String?,
              );
            },
          )
          .toList(),
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, supplierId, closingBalance];
}
