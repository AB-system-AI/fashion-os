import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';

/// Persists media asset metadata via syncable_records (entity_type: media_asset).
class MediaIndexRepository {
  MediaIndexRepository(this._database, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  static const entityType = 'media_asset';

  final AppDatabase _database;
  final Uuid _uuid;

  Future<MediaAsset> save(MediaAsset asset) async {
    final now = DateTime.now().toUtc();
    await _database.syncableRecordDao.insertRecord(
      SyncableRecordsCompanion.insert(
        id: asset.id,
        tenantId: asset.tenantId,
        entityType: entityType,
        storeId: Value(asset.storeId),
        payload: jsonEncode(asset.toJson()),
        version: Value(1),
        createdAt: asset.createdAt,
        updatedAt: now,
        syncStatus: Value(_mapSyncStatus(asset.syncStatus).value),
        isDirty: Value(asset.syncStatus != MediaSyncStatus.synced),
        searchName: Value(asset.filename),
        searchBarcode: Value(asset.checksum),
      ),
    );
    return asset;
  }

  Future<MediaAsset?> getById(String id) async {
    final record = await _database.syncableRecordDao.getById(id);
    if (record == null || record.entityType != entityType) return null;
    return MediaAsset.fromJson(record.payload);
  }

  Future<List<MediaAsset>> listByOwner({
    required String tenantId,
    required String ownerEntityType,
    required String ownerEntityId,
  }) async {
    final rows = await _database.syncableRecordDao.getPage(
      RepositoryQuery(
        tenantId: tenantId,
        entityType: entityType,
        page: 0,
        pageSize: 500,
      ),
    );
    return rows
        .map((r) => MediaAsset.fromJson(r.payload))
        .where((a) => a.ownerEntityType == ownerEntityType && a.ownerEntityId == ownerEntityId)
        .toList();
  }

  Future<List<MediaAsset>> listPendingUpload(String tenantId) async {
    final rows = await _database.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: entityType, page: 0, pageSize: 500),
    );
    return rows
        .map((r) => MediaAsset.fromJson(r.payload))
        .where((a) => a.needsUpload)
        .toList();
  }

  Future<void> delete(String id) async {
    await _database.syncableRecordDao.softDelete(id, DateTime.now().toUtc());
  }

  String newId() => _uuid.v4();

  LocalSyncStatus _mapSyncStatus(MediaSyncStatus status) {
    return switch (status) {
      MediaSyncStatus.synced => LocalSyncStatus.synced,
      MediaSyncStatus.uploading => LocalSyncStatus.syncing,
      MediaSyncStatus.conflict => LocalSyncStatus.conflict,
      MediaSyncStatus.failed => LocalSyncStatus.failed,
      _ => LocalSyncStatus.pending,
    };
  }
}
