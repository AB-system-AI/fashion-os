import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/accounts.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/enums/treasury_enums.dart';

class Cheque extends Equatable with TreasuryEntity {
  const Cheque({
    required this.id,
    required this.tenantId,
    required this.chequeNumber,
    required this.bankAccountId,
    required this.amount,
    required this.payee,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = ChequeStatus.issued,
    this.issueDate,
    this.dueDate,
    this.chequeBookId,
    this.currencyCode = 'USD',
    this.deletedAt,
  });

  static const entityTypeName = 'cheque';

  @override
  final String id;
  @override
  final String tenantId;
  final String chequeNumber;
  final String bankAccountId;
  final String? chequeBookId;
  final ChequeStatus status;
  final double amount;
  final String payee;
  final String currencyCode;
  final DateTime? issueDate;
  final DateTime? dueDate;
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

  Cheque copyWith({ChequeStatus? status, int? version, DateTime? updatedAt, LocalSyncStatus? syncStatus, bool? isDirty}) =>
      Cheque(
        id: id,
        tenantId: tenantId,
        chequeNumber: chequeNumber,
        bankAccountId: bankAccountId,
        chequeBookId: chequeBookId,
        status: status ?? this.status,
        amount: amount,
        payee: payee,
        currencyCode: currencyCode,
        issueDate: issueDate,
        dueDate: dueDate,
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
        'cheque_number': chequeNumber,
        'bank_account_id': bankAccountId,
        'cheque_book_id': chequeBookId,
        'status': status.value,
        'amount': amount,
        'payee': payee,
        'currency_code': currencyCode,
        'issue_date': issueDate?.toIso8601String(),
        'due_date': dueDate?.toIso8601String(),
      };

  static Cheque fromPayload(Map<String, dynamic> json, LocalRecord record) => Cheque(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        chequeNumber: json['cheque_number'] as String? ?? record.searchName ?? '',
        bankAccountId: json['bank_account_id'] as String? ?? '',
        chequeBookId: json['cheque_book_id'] as String?,
        status: ChequeStatus.fromValue(json['status'] as String?),
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        payee: json['payee'] as String? ?? '',
        currencyCode: json['currency_code'] as String? ?? 'USD',
        issueDate: json['issue_date'] != null ? DateTime.tryParse(json['issue_date'] as String) : null,
        dueDate: json['due_date'] != null ? DateTime.tryParse(json['due_date'] as String) : null,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, chequeNumber, status, amount, version];
}

class ChequeBook extends Equatable with TreasuryEntity {
  const ChequeBook({
    required this.id,
    required this.tenantId,
    required this.bankAccountId,
    required this.startNumber,
    required this.endNumber,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.nextNumber,
    this.isActive = true,
    this.deletedAt,
  });

  static const entityTypeName = 'cheque_book';

  @override
  final String id;
  @override
  final String tenantId;
  final String bankAccountId;
  final int startNumber;
  final int endNumber;
  final int? nextNumber;
  final bool isActive;
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
        'start_number': startNumber,
        'end_number': endNumber,
        'next_number': nextNumber,
        'is_active': isActive,
      };

  static ChequeBook fromPayload(Map<String, dynamic> json, LocalRecord record) => ChequeBook(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        bankAccountId: json['bank_account_id'] as String? ?? '',
        startNumber: json['start_number'] as int? ?? 0,
        endNumber: json['end_number'] as int? ?? 0,
        nextNumber: json['next_number'] as int?,
        isActive: json['is_active'] as bool? ?? true,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, bankAccountId, startNumber, endNumber, version];
}
