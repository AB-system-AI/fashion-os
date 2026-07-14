import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/enums/assets_enums.dart';

class AssetDisposal extends Equatable implements SyncableEntity {
  const AssetDisposal({
    required this.id,
    required this.tenantId,
    required this.assetId,
    required this.method,
    required this.bookValueAtDisposal,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.proceeds = 0,
    this.gainLoss = 0,
    this.notes,
    this.disposedAt,
    this.disposedBy,
    this.journalEntryId,
    this.deletedAt,
  });

  static const entityTypeName = 'asset_disposal';

  @override
  final String id;
  @override
  final String tenantId;
  final String assetId;
  final DisposalMethod method;
  final double proceeds;
  final double bookValueAtDisposal;
  final double gainLoss;
  final String? notes;
  final DateTime? disposedAt;
  final String? disposedBy;
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
        'method': method.value,
        'proceeds': proceeds,
        'book_value_at_disposal': bookValueAtDisposal,
        'gain_loss': gainLoss,
        'notes': notes,
        'disposed_at': disposedAt?.toIso8601String(),
        'disposed_by': disposedBy,
        'journal_entry_id': journalEntryId,
        'version': version,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  static AssetDisposal fromPayload(Map<String, dynamic> json, LocalRecord record) => AssetDisposal(
        id: json['id'] as String? ?? record.id,
        tenantId: json['tenant_id'] as String? ?? record.tenantId,
        assetId: json['asset_id'] as String? ?? '',
        method: DisposalMethod.fromValue(json['method'] as String?),
        proceeds: (json['proceeds'] as num?)?.toDouble() ?? 0,
        bookValueAtDisposal: (json['book_value_at_disposal'] as num?)?.toDouble() ?? 0,
        gainLoss: (json['gain_loss'] as num?)?.toDouble() ?? 0,
        notes: json['notes'] as String?,
        disposedAt: json['disposed_at'] != null ? DateTime.tryParse(json['disposed_at'] as String) : null,
        disposedBy: json['disposed_by'] as String?,
        journalEntryId: json['journal_entry_id'] as String?,
        version: record.version,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
        deletedAt: record.deletedAt,
        syncStatus: record.syncStatus,
        isDirty: record.isDirty,
      );

  @override
  List<Object?> get props => [id, assetId, method, gainLoss];
}
