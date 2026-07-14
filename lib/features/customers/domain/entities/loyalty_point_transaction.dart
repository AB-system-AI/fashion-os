import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/enums/customer_enums.dart';

class LoyaltyPointTransaction extends Equatable implements SyncableEntity {
  const LoyaltyPointTransaction({
    required this.id,
    required this.tenantId,
    required this.accountId,
    required this.customerId,
    required this.transactionType,
    required this.points,
    required this.balanceAfter,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.referenceType,
    this.referenceId,
    this.description,
    this.expiresAt,
    this.deletedAt,
  });

  static const entityTypeName = 'loyalty_point_transaction';

  @override
  final String id;
  @override
  final String tenantId;
  final String accountId;
  final String customerId;
  final LoyaltyPointLedgerType transactionType;
  final int points;
  final int balanceAfter;
  final String? referenceType;
  final String? referenceId;
  final String? description;
  final DateTime? expiresAt;
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
        'account_id': accountId,
        'customer_id': customerId,
        'transaction_type': transactionType.value,
        'points': points,
        'balance_after': balanceAfter,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'description': description,
        'expires_at': expiresAt?.toIso8601String(),
        'version': version,
      };

  factory LoyaltyPointTransaction.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return LoyaltyPointTransaction(
      id: record.id,
      tenantId: record.tenantId,
      accountId: json['account_id'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? record.storeId ?? '',
      transactionType: LoyaltyPointLedgerType.fromValue(json['transaction_type'] as String?),
      points: (json['points'] as num?)?.toInt() ?? 0,
      balanceAfter: (json['balance_after'] as num?)?.toInt() ?? 0,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      description: json['description'] as String?,
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'] as String) : null,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, accountId, points];
}
