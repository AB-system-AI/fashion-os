import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/enums/accounting_enums.dart';

class BankAccount extends Equatable implements SyncableEntity {
  const BankAccount({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.accountNumber,
    required this.currency,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.glAccountId,
    this.bankName,
    this.iban,
    this.balance = 0,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'bank_account';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String accountNumber;
  final String currency;
  final String? glAccountId;
  final String? bankName;
  final String? iban;
  final double balance;
  final bool active;
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
        'name': name,
        'account_number': accountNumber,
        'currency': currency,
        'gl_account_id': glAccountId,
        'bank_name': bankName,
        'iban': iban,
        'balance': balance,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static BankAccount fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return BankAccount(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      name: json['name'] as String? ?? '',
      accountNumber: json['account_number'] as String? ?? '',
      currency: json['currency'] as String? ?? 'USD',
      glAccountId: json['gl_account_id'] as String?,
      bankName: json['bank_name'] as String?,
      iban: json['iban'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      active: json['is_active'] as bool? ?? true,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, accountNumber];
}

class BankTransaction extends Equatable implements SyncableEntity {
  const BankTransaction({
    required this.id,
    required this.tenantId,
    required this.bankAccountId,
    required this.transactionType,
    required this.amount,
    required this.transactionDate,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.reference,
    this.description,
    this.reconciled = false,
    this.journalEntryId,
    this.deletedAt,
  });

  static const entityTypeName = 'bank_transaction';

  @override
  final String id;
  @override
  final String tenantId;
  final String bankAccountId;
  final BankTransactionType transactionType;
  final double amount;
  final DateTime transactionDate;
  final String? reference;
  final String? description;
  final bool reconciled;
  final String? journalEntryId;
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
        'bank_account_id': bankAccountId,
        'transaction_type': transactionType.value,
        'amount': amount,
        'transaction_date': transactionDate.toIso8601String().split('T').first,
        'reference': reference,
        'description': description,
        'is_reconciled': reconciled,
        'journal_entry_id': journalEntryId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static BankTransaction fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return BankTransaction(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      bankAccountId: json['bank_account_id'] as String? ?? '',
      transactionType: BankTransactionType.fromValue(json['transaction_type'] as String?),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      transactionDate: DateTime.tryParse(json['transaction_date'] as String? ?? '') ?? record.createdAt,
      reference: json['reference'] as String?,
      description: json['description'] as String?,
      reconciled: json['is_reconciled'] as bool? ?? false,
      journalEntryId: json['journal_entry_id'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, bankAccountId, amount];
}

class CashAccount extends Equatable implements SyncableEntity {
  const CashAccount({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.storeId,
    required this.currency,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.glAccountId,
    this.balance = 0,
    this.active = true,
    this.deletedAt,
  });

  static const entityTypeName = 'cash_account';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String storeId;
  final String currency;
  final String? glAccountId;
  final double balance;
  final bool active;
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
        'name': name,
        'store_id': storeId,
        'currency': currency,
        'gl_account_id': glAccountId,
        'balance': balance,
        'is_active': active,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static CashAccount fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return CashAccount(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      name: json['name'] as String? ?? '',
      storeId: json['store_id'] as String? ?? '',
      currency: json['currency'] as String? ?? 'USD',
      glAccountId: json['gl_account_id'] as String?,
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      active: json['is_active'] as bool? ?? true,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, storeId];
}
