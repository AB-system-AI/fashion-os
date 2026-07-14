import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/enums/accounting_enums.dart';

class LedgerTransaction extends Equatable implements SyncableEntity {
  const LedgerTransaction({
    required this.id,
    required this.tenantId,
    required this.accountId,
    required this.journalEntryId,
    required this.entryDate,
    required this.debit,
    required this.credit,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.storeId,
    this.accountCode,
    this.description,
    this.referenceType,
    this.referenceId,
    this.costCenterId,
    this.currency = 'USD',
    this.runningBalance,
    this.deletedAt,
  });

  static const entityTypeName = 'ledger_transaction';

  @override
  final String id;
  @override
  final String tenantId;
  final String? storeId;
  final String accountId;
  final String? accountCode;
  final String journalEntryId;
  final DateTime entryDate;
  final double debit;
  final double credit;
  final String? description;
  final String? referenceType;
  final String? referenceId;
  final String? costCenterId;
  final String currency;
  final double? runningBalance;
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
        'account_id': accountId,
        'account_code': accountCode,
        'journal_entry_id': journalEntryId,
        'entry_date': entryDate.toIso8601String().split('T').first,
        'debit': debit,
        'credit': credit,
        'description': description,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'cost_center_id': costCenterId,
        'currency': currency,
        'running_balance': runningBalance,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static LedgerTransaction fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return LedgerTransaction(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      storeId: json['store_id'] as String?,
      accountId: json['account_id'] as String? ?? '',
      accountCode: json['account_code'] as String?,
      journalEntryId: json['journal_entry_id'] as String? ?? '',
      entryDate: DateTime.tryParse(json['entry_date'] as String? ?? '') ?? record.createdAt,
      debit: (json['debit'] as num?)?.toDouble() ?? 0,
      credit: (json['credit'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String?,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      costCenterId: json['cost_center_id'] as String?,
      currency: json['currency'] as String? ?? 'USD',
      runningBalance: (json['running_balance'] as num?)?.toDouble(),
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, accountId, journalEntryId];
}
