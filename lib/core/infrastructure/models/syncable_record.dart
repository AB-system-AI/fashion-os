import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';

/// Base contract for all locally persisted syncable entities.
abstract class SyncableEntity extends Equatable {
  const SyncableEntity();

  String get id;
  String get tenantId;
  String get entityType;
  int get version;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  LocalSyncStatus get syncStatus;
  bool get isDirty;

  bool get isDeleted => deletedAt != null;

  Map<String, dynamic> toPayload();
}

/// Domain model mapped from [SyncableRecords] table rows.
class LocalRecord extends SyncableEntity {
  const LocalRecord({
    required this.id,
    required this.tenantId,
    required this.entityType,
    required this.payload,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.isDirty,
    this.deletedAt,
    this.searchName,
    this.searchSku,
    this.searchBarcode,
    this.storeId,
  });

  @override
  final String id;
  @override
  final String tenantId;
  @override
  final String entityType;
  final Map<String, dynamic> payload;
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
  final String? searchName;
  final String? searchSku;
  final String? searchBarcode;
  final String? storeId;

  LocalRecord copyWith({
    Map<String, dynamic>? payload,
    int? version,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    LocalSyncStatus? syncStatus,
    bool? isDirty,
    String? searchName,
    String? searchSku,
    String? searchBarcode,
    String? storeId,
  }) {
    return LocalRecord(
      id: id,
      tenantId: tenantId,
      entityType: entityType,
      payload: payload ?? this.payload,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isDirty: isDirty ?? this.isDirty,
      searchName: searchName ?? this.searchName,
      searchSku: searchSku ?? this.searchSku,
      searchBarcode: searchBarcode ?? this.searchBarcode,
      storeId: storeId ?? this.storeId,
    );
  }

  @override
  Map<String, dynamic> toPayload() => payload;

  @override
  List<Object?> get props => [
        id,
        tenantId,
        entityType,
        version,
        updatedAt,
        deletedAt,
        syncStatus,
        isDirty,
      ];
}
