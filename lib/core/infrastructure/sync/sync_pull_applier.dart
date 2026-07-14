import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/remote_sync_record.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';
import 'package:uuid/uuid.dart';

/// Applies inbound remote sync records to local Drift storage.
class SyncPullApplier {
  SyncPullApplier(this._db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final Uuid _uuid;

  Future<int> applyAll({
    required String tenantId,
    required List<RemoteSyncRecord> records,
  }) async {
    var applied = 0;
    for (final remote in records) {
      if (remote.tenantId != tenantId) {
        AppLogger.warning('Skipped remote record ${remote.id} — tenant mismatch');
        continue;
      }
      final didApply = await applyOne(remote: remote, tenantId: tenantId);
      if (didApply) applied++;
    }
    return applied;
  }

  Future<bool> applyOne({
    required RemoteSyncRecord remote,
    required String tenantId,
  }) async {
    if (remote.tenantId != tenantId) return false;

    final local = await _db.syncableRecordDao.getById(remote.id, tenantId: tenantId);

    if (local != null && local.isDirty && local.version > remote.version) {
      await _logConflict(
        tenantId: tenantId,
        entityType: remote.entityType,
        entityId: remote.id,
        clientPayload: local.payload,
        serverPayload: remote.payload,
        clientVersion: local.version,
        serverVersion: remote.version,
        status: 'pending_manual',
      );
      return false;
    }

    if (remote.isDeleted) {
      await _db.syncableRecordDao.softDelete(remote.id, remote.deletedAt!, tenantId: tenantId);
      return true;
    }

    final now = remote.updatedAt.toUtc();
    await _db.syncableRecordDao.upsertFromRemote(
      SyncableRecordsCompanion.insert(
        id: remote.id,
        tenantId: remote.tenantId,
        entityType: remote.entityType,
        storeId: Value(remote.storeId),
        payload: jsonEncode(remote.payload),
        version: Value(remote.version),
        createdAt: local?.createdAt ?? now,
        updatedAt: now,
        deletedAt: const Value(null),
        syncStatus: const Value('synced'),
        isDirty: const Value(false),
        searchName: Value(remote.searchName ?? remote.payload['name']?.toString()),
        searchSku: Value(remote.searchSku ?? remote.payload['sku']?.toString()),
        searchBarcode: Value(remote.searchBarcode ?? remote.payload['barcode']?.toString()),
      ),
    );
    return true;
  }

  Future<void> applyResolvedPayload({
    required String tenantId,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> payload,
    required int version,
    required ConflictResolutionStrategy strategy,
  }) async {
    final now = DateTime.now().toUtc();
    await _db.syncableRecordDao.upsertFromRemote(
      SyncableRecordsCompanion.insert(
        id: entityId,
        tenantId: tenantId,
        entityType: entityType,
        payload: jsonEncode(payload),
        version: Value(version),
        createdAt: now,
        updatedAt: now,
        syncStatus: const Value('synced'),
        isDirty: const Value(false),
        searchName: Value(payload['name']?.toString()),
        searchSku: Value(payload['sku']?.toString()),
        searchBarcode: Value(payload['barcode']?.toString()),
      ),
    );
    await _logConflict(
      tenantId: tenantId,
      entityType: entityType,
      entityId: entityId,
      clientPayload: payload,
      serverPayload: payload,
      clientVersion: version,
      serverVersion: version,
      status: 'resolved_${strategy.value}',
    );
  }

  Future<void> _logConflict({
    required String tenantId,
    required String entityType,
    required String entityId,
    required Map<String, dynamic> clientPayload,
    required Map<String, dynamic> serverPayload,
    required int clientVersion,
    required int serverVersion,
    required String status,
  }) {
    return _db.syncConflictDao.insertConflict(
      SyncConflictHistoryCompanion.insert(
        id: _uuid.v4(),
        tenantId: tenantId,
        entityType: entityType,
        entityId: entityId,
        clientPayload: jsonEncode(clientPayload),
        serverPayload: jsonEncode(serverPayload),
        clientVersion: clientVersion,
        serverVersion: serverVersion,
        status: status,
        createdAt: DateTime.now().toUtc(),
      ),
    );
  }
}
