import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/entities/journal_line.dart';
import 'package:fashion_pos_enterprise/features/accounting/domain/enums/accounting_enums.dart';

class JournalEntry extends Equatable implements SyncableEntity {
  const JournalEntry({
    required this.id,
    required this.tenantId,
    required this.entryNumber,
    required this.entryDate,
    required this.lines,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.storeId,
    this.status = JournalStatus.draft,
    this.source = JournalSource.manual,
    this.referenceType,
    this.referenceId,
    this.description,
    this.fiscalPeriodId,
    this.currency = 'USD',
    this.postedAt,
    this.reversedEntryId,
    this.deletedAt,
  });

  static const entityTypeName = 'journal_entry';

  @override
  final String id;
  @override
  final String tenantId;
  final String? storeId;
  final String entryNumber;
  final DateTime entryDate;
  final JournalStatus status;
  final JournalSource source;
  final String? referenceType;
  final String? referenceId;
  final String? description;
  final String? fiscalPeriodId;
  final String currency;
  final List<JournalLine> lines;
  final DateTime? postedAt;
  final String? reversedEntryId;
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

  double get totalDebit => lines.fold(0.0, (s, l) => s + l.debit);
  double get totalCredit => lines.fold(0.0, (s, l) => s + l.credit);

  @override
  String get entityType => entityTypeName;

  @override
  Map<String, dynamic> toPayload() => {
        'id': id,
        'tenant_id': tenantId,
        'store_id': storeId,
        'entry_number': entryNumber,
        'entry_date': entryDate.toIso8601String().split('T').first,
        'status': status.value,
        'source': source.value,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'description': description,
        'fiscal_period_id': fiscalPeriodId,
        'currency': currency,
        'lines': lines.map((l) => l.toJson()).toList(),
        'total_debit': totalDebit,
        'total_credit': totalCredit,
        'posted_at': postedAt?.toIso8601String(),
        'reversed_entry_id': reversedEntryId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static JournalEntry fromPayload(Map<String, dynamic> json, LocalRecord record) {
    final linesJson = json['lines'] as List? ?? [];
    return JournalEntry(
      id: json['id'] as String? ?? record.id,
      tenantId: json['tenant_id'] as String? ?? record.tenantId,
      storeId: json['store_id'] as String?,
      entryNumber: json['entry_number'] as String? ?? '',
      entryDate: DateTime.tryParse(json['entry_date'] as String? ?? '') ?? record.createdAt,
      status: JournalStatus.fromValue(json['status'] as String?),
      source: JournalSource.fromValue(json['source'] as String?),
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as String?,
      description: json['description'] as String?,
      fiscalPeriodId: json['fiscal_period_id'] as String?,
      currency: json['currency'] as String? ?? 'USD',
      lines: linesJson.map((e) => JournalLine.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      postedAt: json['posted_at'] != null ? DateTime.tryParse(json['posted_at'] as String) : null,
      reversedEntryId: json['reversed_entry_id'] as String?,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  JournalEntry copyWith({
    JournalStatus? status,
    List<JournalLine>? lines,
    DateTime? postedAt,
    int? version,
    DateTime? updatedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return JournalEntry(
      id: id,
      tenantId: tenantId,
      storeId: storeId,
      entryNumber: entryNumber,
      entryDate: entryDate,
      status: status ?? this.status,
      source: source,
      referenceType: referenceType,
      referenceId: referenceId,
      description: description,
      fiscalPeriodId: fiscalPeriodId,
      currency: currency,
      lines: lines ?? this.lines,
      postedAt: postedAt ?? this.postedAt,
      reversedEntryId: reversedEntryId,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, entryNumber, status];
}
