import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/enums/accounting_enums.dart';

class FinancialAttachment extends Equatable implements SyncableEntity {
  const FinancialAttachment({
    required this.id,
    required this.tenantId,
    required this.fileName,
    required this.fileUrl,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.documentId,
    this.mimeType,
    this.fileSize,
    this.deletedAt,
  });

  static const entityTypeName = 'financial_attachment';

  @override
  final String id;
  @override
  final String tenantId;
  final String? documentId;
  final String fileName;
  final String fileUrl;
  final String? mimeType;
  final int? fileSize;
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
        'document_id': documentId,
        'file_name': fileName,
        'file_url': fileUrl,
        'mime_type': mimeType,
        'file_size': fileSize,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static FinancialAttachment fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return FinancialAttachment(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      documentId: json['document_id'] as String?,
      fileName: json['file_name'] as String? ?? '',
      fileUrl: json['file_url'] as String? ?? '',
      mimeType: json['mime_type'] as String?,
      fileSize: (json['file_size'] as num?)?.toInt(),
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, fileName];
}

class FinancialDocument extends Equatable implements SyncableEntity {
  const FinancialDocument({
    required this.id,
    required this.tenantId,
    required this.documentNumber,
    required this.documentType,
    required this.documentDate,
    required this.amount,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.storeId,
    this.currency = 'USD',
    this.partyType,
    this.partyId,
    this.journalEntryId,
    this.notes,
    this.deletedAt,
  });

  static const entityTypeName = 'financial_document';

  @override
  final String id;
  @override
  final String tenantId;
  final String? storeId;
  final String documentNumber;
  final FinancialDocumentType documentType;
  final DateTime documentDate;
  final double amount;
  final String currency;
  final String? partyType;
  final String? partyId;
  final String? journalEntryId;
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

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'store_id': storeId,
        'document_number': documentNumber,
        'document_type': documentType.value,
        'document_date': documentDate.toIso8601String().split('T').first,
        'amount': amount,
        'currency': currency,
        'party_type': partyType,
        'party_id': partyId,
        'journal_entry_id': journalEntryId,
        'notes': notes,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static FinancialDocument fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return FinancialDocument(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      storeId: json['store_id'] as String?,
      documentNumber: json['document_number'] as String? ?? '',
      documentType: FinancialDocumentType.fromValue(json['document_type'] as String?),
      documentDate: DateTime.tryParse(json['document_date'] as String? ?? '') ?? record.createdAt,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      partyType: json['party_type'] as String?,
      partyId: json['party_id'] as String?,
      journalEntryId: json['journal_entry_id'] as String?,
      notes: json['notes'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, documentNumber];
}

class ReconciliationSession extends Equatable implements SyncableEntity {
  const ReconciliationSession({
    required this.id,
    required this.tenantId,
    required this.bankAccountId,
    required this.statementDate,
    required this.statementBalance,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.status = ReconciliationStatus.open,
    this.bookBalance,
    this.difference,
    this.completedAt,
    this.deletedAt,
  });

  static const entityTypeName = 'reconciliation_session';

  @override
  final String id;
  @override
  final String tenantId;
  final String bankAccountId;
  final DateTime statementDate;
  final double statementBalance;
  final ReconciliationStatus status;
  final double? bookBalance;
  final double? difference;
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
        'bank_account_id': bankAccountId,
        'statement_date': statementDate.toIso8601String().split('T').first,
        'statement_balance': statementBalance,
        'status': status.value,
        'book_balance': bookBalance,
        'difference': difference,
        'completed_at': completedAt?.toIso8601String(),
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static ReconciliationSession fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return ReconciliationSession(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      bankAccountId: json['bank_account_id'] as String? ?? '',
      statementDate: DateTime.tryParse(json['statement_date'] as String? ?? '') ?? record.createdAt,
      statementBalance: (json['statement_balance'] as num?)?.toDouble() ?? 0,
      status: ReconciliationStatus.fromValue(json['status'] as String?),
      bookBalance: (json['book_balance'] as num?)?.toDouble(),
      difference: (json['difference'] as num?)?.toDouble(),
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
  List<Object?> get props => [id, bankAccountId, statementDate];
}
