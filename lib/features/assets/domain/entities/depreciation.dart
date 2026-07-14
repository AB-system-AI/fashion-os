import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/enums/assets_enums.dart';

class AssetDepreciation extends Equatable implements SyncableEntity {
  const AssetDepreciation({
    required this.id,
    required this.tenantId,
    required this.assetId,
    required this.period,
    required this.depreciationAmount,
    required this.accumulatedDepreciation,
    required this.bookValue,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.postedAt,
    this.journalEntryId,
    this.deletedAt,
  });

  static const entityTypeName = 'asset_depreciation';

  @override
  final String id;
  @override
  final String tenantId;
  final String assetId;
  final int period;
  final double depreciationAmount;
  final double accumulatedDepreciation;
  final double bookValue;
  final DateTime? postedAt;
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
        'asset_id': assetId,
        'period': period,
        'depreciation_amount': depreciationAmount,
        'accumulated_depreciation': accumulatedDepreciation,
        'book_value': bookValue,
        'posted_at': postedAt?.toIso8601String(),
        'journal_entry_id': journalEntryId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static AssetDepreciation fromPayload(Map<String, dynamic> json, LocalRecord record) => AssetDepreciation(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        assetId: json['asset_id'] as String? ?? '',
        period: json['period'] as int? ?? 0,
        depreciationAmount: (json['depreciation_amount'] as num?)?.toDouble() ?? 0,
        accumulatedDepreciation: (json['accumulated_depreciation'] as num?)?.toDouble() ?? 0,
        bookValue: (json['book_value'] as num?)?.toDouble() ?? 0,
        postedAt: json['posted_at'] != null ? DateTime.tryParse(json['posted_at'] as String) : null,
        journalEntryId: json['journal_entry_id'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, assetId, period, bookValue];
}
