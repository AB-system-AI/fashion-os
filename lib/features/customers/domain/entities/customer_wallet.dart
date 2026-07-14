import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/enums/customer_enums.dart';

class WalletTransaction extends Equatable {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.occurredAt,
    this.reference,
    this.notes,
  });

  final String id;
  final WalletTransactionType type;
  final double amount;
  final double balanceAfter;
  final DateTime occurredAt;
  final String? reference;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.value,
        'amount': amount,
        'balance_after': balanceAfter,
        'occurred_at': occurredAt.toIso8601String(),
        'reference': reference,
        'notes': notes,
      };

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String? ?? '',
      type: WalletTransactionType.fromValue(json['type'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      balanceAfter: (json['balance_after'] as num?)?.toDouble() ?? 0,
      occurredAt: DateTime.tryParse(json['occurred_at'] as String? ?? '') ?? DateTime.now().toUtc(),
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, type, amount];
}

class CustomerWallet extends Equatable implements SyncableEntity {
  const CustomerWallet({
    required this.id,
    required this.tenantId,
    required this.customerId,
    required this.balance,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.currency = 'USD',
    this.transactions = const [],
    this.deletedAt,
  });

  static const entityTypeName = 'customer_wallet';

  @override
  final String id;
  @override
  final String tenantId;
  final String customerId;
  final double balance;
  final String currency;
  final List<WalletTransaction> transactions;
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
        'balance': balance,
        'currency': currency,
        'transactions': transactions.map((t) => t.toJson()).toList(),
        'version': version,
      };

  factory CustomerWallet.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final raw = json['transactions'] as List<dynamic>? ?? const [];
    return CustomerWallet(
      id: record.id,
      tenantId: record.tenantId,
      customerId: json['customer_id'] as String? ?? record.storeId ?? '',
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      transactions: raw.map((e) => WalletTransaction.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  CustomerWallet copyWith({
    double? balance,
    List<WalletTransaction>? transactions,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return CustomerWallet(
      id: id,
      tenantId: tenantId,
      customerId: customerId,
      balance: balance ?? this.balance,
      currency: currency,
      transactions: transactions ?? this.transactions,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, customerId, balance];
}
