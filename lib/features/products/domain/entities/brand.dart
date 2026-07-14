import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

/// Product brand master record.
class Brand extends Equatable implements SyncableEntity {
  const Brand({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.logoAssetId,
    this.country,
    this.description,
    this.isActive = true,
    this.deletedAt,
  });

  static const entityTypeName = 'brand';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? logoAssetId;
  final String? country;
  final String? description;
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
        'id': id,
        'name': name,
        'logo_asset_id': logoAssetId,
        'country': country,
        'description': description,
        'is_active': isActive,
      };

  factory Brand.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Brand(
      id: record.id,
      tenantId: record.tenantId,
      name: json['name'] as String? ?? record.searchName ?? '',
      logoAssetId: json['logo_asset_id'] as String?,
      country: json['country'] as String?,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      version: record.version,
      createdAt: record.createdAt,
      updatedAt: record.updatedAt,
      deletedAt: record.deletedAt,
      syncStatus: record.syncStatus,
      isDirty: record.isDirty,
    );
  }

  @override
  List<Object?> get props => [id, name];

  Brand copyWith({
    String? name,
    String? logoAssetId,
    String? country,
    String? description,
    bool? isActive,
    int? version,
    DateTime? updatedAt,
    DateTime? deletedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return Brand(
      id: id,
      tenantId: tenantId,
      name: name ?? this.name,
      logoAssetId: logoAssetId ?? this.logoAssetId,
      country: country ?? this.country,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      version: version ?? this.version,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
    );
  }
}
