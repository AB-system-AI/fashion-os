import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';

/// Hierarchical merchandise category.
class Category extends Equatable implements SyncableEntity {
  const Category({
    required this.id,
    required this.tenantId,
    required this.name,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.parentId,
    this.path,
    this.iconName,
    this.imageAssetId,
    this.sortOrder = 0,
    this.isActive = true,
    this.deletedAt,
  });

  static const entityTypeName = 'category';

  @override
  final String id;
  @override
  final String tenantId;
  final String name;
  final String? parentId;
  final String? path;
  final String? iconName;
  final String? imageAssetId;
  final int sortOrder;
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
        'parent_id': parentId,
        'path': path,
        'icon_name': iconName,
        'image_asset_id': imageAssetId,
        'sort_order': sortOrder,
        'is_active': isActive,
      };

  factory Category.fromPayload(Map<String, dynamic> json, LocalRecord record) {
    return Category(
      id: record.id,
      tenantId: record.tenantId,
      name: json['name'] as String? ?? record.searchName ?? '',
      parentId: json['parent_id'] as String?,
      path: json['path'] as String?,
      iconName: json['icon_name'] as String?,
      imageAssetId: json['image_asset_id'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
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
  List<Object?> get props => [id, name, parentId];

  Category copyWith({
    String? name,
    String? parentId,
    String? path,
    String? iconName,
    String? imageAssetId,
    int? sortOrder,
    bool? isActive,
    int? version,
    DateTime? updatedAt,
    DateTime? deletedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
  }) {
    return Category(
      id: id,
      tenantId: tenantId,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      path: path ?? this.path,
      iconName: iconName ?? this.iconName,
      imageAssetId: imageAssetId ?? this.imageAssetId,
      sortOrder: sortOrder ?? this.sortOrder,
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
