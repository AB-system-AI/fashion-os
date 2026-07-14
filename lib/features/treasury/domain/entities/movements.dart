import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/accounts.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/enums/treasury_enums.dart';

class CashMovement extends Equatable with TreasuryEntity {
  const CashMovement({
    required this.id,
    required this.tenantId,
    required this.cashBoxId,
    required this.direction,
    required this.amount,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.reference,
    this.description,
    this.currencyCode = 'USD',
    this.deletedAt,
  });

  static const entityTypeName = 'cash_movement';

  @override
  final String id;
  @override
  final String tenantId;
  final String cashBoxId;
  final MovementDirection direction;
  final double amount;
  final String currencyCode;
  final String? reference;
  final String? description;
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
        ...basePayload(),
        'cash_box_id': cashBoxId,
        'direction': direction.value,
        'amount': amount,
        'currency_code': currencyCode,
        'reference': reference,
        'description': description,
      };

  static CashMovement fromPayload(Map<String, dynamic> json, LocalRecord record) => CashMovement(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        cashBoxId: json['cash_box_id'] as String? ?? '',
        direction: MovementDirection.fromValue(json['direction'] as String?),
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        currencyCode: json['currency_code'] as String? ?? 'USD',
        reference: json['reference'] as String?,
        description: json['description'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, cashBoxId, amount, direction, version];
}

class BankMovement extends Equatable with TreasuryEntity {
  const BankMovement({
    required this.id,
    required this.tenantId,
    required this.bankAccountId,
    required this.direction,
    required this.amount,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.reference,
    this.description,
    this.currencyCode = 'USD',
    this.deletedAt,
  });

  static const entityTypeName = 'bank_movement';

  @override
  final String id;
  @override
  final String tenantId;
  final String bankAccountId;
  final MovementDirection direction;
  final double amount;
  final String currencyCode;
  final String? reference;
  final String? description;
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
        ...basePayload(),
        'bank_account_id': bankAccountId,
        'direction': direction.value,
        'amount': amount,
        'currency_code': currencyCode,
        'reference': reference,
        'description': description,
      };

  static BankMovement fromPayload(Map<String, dynamic> json, LocalRecord record) => BankMovement(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        bankAccountId: json['bank_account_id'] as String? ?? '',
        direction: MovementDirection.fromValue(json['direction'] as String?),
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        currencyCode: json['currency_code'] as String? ?? 'USD',
        reference: json['reference'] as String?,
        description: json['description'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, bankAccountId, amount, version];
}

class Transfer extends Equatable with TreasuryEntity {
  const Transfer({
    required this.id,
    required this.tenantId,
    required this.transferNumber,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = TransferStatus.draft,
    this.currencyCode = 'USD',
    this.exchangeRate = 1,
    this.notes,
    this.deletedAt,
  });

  static const entityTypeName = 'transfer';

  @override
  final String id;
  @override
  final String tenantId;
  final String transferNumber;
  final String fromAccountId;
  final String toAccountId;
  final TransferStatus status;
  final double amount;
  final String currencyCode;
  final double exchangeRate;
  final String? notes;
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

  Transfer copyWith({TransferStatus? status, int? version, DateTime? updatedAt, LocalSyncStatus? syncStatus, bool? isDirty}) =>
      Transfer(
        id: id,
        tenantId: tenantId,
        transferNumber: transferNumber,
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        status: status ?? this.status,
        amount: amount,
        currencyCode: currencyCode,
        exchangeRate: exchangeRate,
        notes: notes,
        version: version ?? this.version,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        deletedAt: deletedAt,
        syncStatus: syncStatus ?? this.syncStatus,
        isDirty: isDirty ?? this.isDirty,
      );

  @override
  Map<String, dynamic> toPayload() => {
        ...basePayload(),
        'transfer_number': transferNumber,
        'from_account_id': fromAccountId,
        'to_account_id': toAccountId,
        'status': status.value,
        'amount': amount,
        'currency_code': currencyCode,
        'exchange_rate': exchangeRate,
        'notes': notes,
      };

  static Transfer fromPayload(Map<String, dynamic> json, LocalRecord record) => Transfer(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        transferNumber: json['transfer_number'] as String? ?? record.searchName ?? '',
        fromAccountId: json['from_account_id'] as String? ?? '',
        toAccountId: json['to_account_id'] as String? ?? '',
        status: TransferStatus.fromValue(json['status'] as String?),
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        currencyCode: json['currency_code'] as String? ?? 'USD',
        exchangeRate: (json['exchange_rate'] as num?)?.toDouble() ?? 1,
        notes: json['notes'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, transferNumber, status, amount, version];
}

class TreasuryTransaction extends Equatable with TreasuryEntity {
  const TreasuryTransaction({
    required this.id,
    required this.tenantId,
    required this.transactionType,
    required this.amount,
    required this.accountId,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.referenceType,
    this.referenceId,
    this.currencyCode = 'USD',
    this.deletedAt,
  });

  static const entityTypeName = 'treasury_transaction';

  @override
  final String id;
  @override
  final String tenantId;
  final TreasuryTransactionType transactionType;
  final double amount;
  final String accountId;
  final String? referenceType;
  final String? referenceId;
  final String currencyCode;
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
        ...basePayload(),
        'transaction_type': transactionType.value,
        'amount': amount,
        'account_id': accountId,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'currency_code': currencyCode,
      };

  static TreasuryTransaction fromPayload(Map<String, dynamic> json, LocalRecord record) => TreasuryTransaction(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        transactionType: TreasuryTransactionType.fromValue(json['transaction_type'] as String?),
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        accountId: json['account_id'] as String? ?? '',
        referenceType: json['reference_type'] as String?,
        referenceId: json['reference_id'] as String?,
        currencyCode: json['currency_code'] as String? ?? 'USD',
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, transactionType, amount, version];
}
