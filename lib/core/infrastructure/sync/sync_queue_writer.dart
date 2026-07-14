import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:uuid/uuid.dart';

/// Writes outbound sync operations to the local queue.
class SyncQueueWriter {
  SyncQueueWriter(this._database, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase _database;
  final Uuid _uuid;

  Future<String> enqueue({
    required String tenantId,
    required String entityType,
    required String entityId,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
    int clientVersion = 1,
    ConflictResolutionStrategy? conflictStrategy,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    await _database.syncQueueDao.enqueue(
      SyncQueueItemsCompanion.insert(
        id: id,
        tenantId: tenantId,
        entityType: entityType,
        entityId: entityId,
        operation: operation.value,
        payload: jsonEncode(payload),
        clientVersion: Value(clientVersion),
        status: const Value('pending'),
        retryCount: const Value(0),
        createdAt: now,
        updatedAt: now,
        scheduledAt: Value(now),
        conflictStrategy: Value(conflictStrategy?.value),
      ),
    );
    return id;
  }

  /// Enqueues inside an existing transaction (used by repositories).
  Future<String> enqueueInTransaction({
    required String tenantId,
    required String entityType,
    required String entityId,
    required SyncOperation operation,
    required Map<String, dynamic> payload,
    int clientVersion = 1,
    ConflictResolutionStrategy? conflictStrategy,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    await _database.syncQueueDao.enqueue(
      SyncQueueItemsCompanion.insert(
        id: id,
        tenantId: tenantId,
        entityType: entityType,
        entityId: entityId,
        operation: operation.value,
        payload: jsonEncode(payload),
        clientVersion: Value(clientVersion),
        status: const Value('pending'),
        retryCount: const Value(0),
        createdAt: now,
        updatedAt: now,
        scheduledAt: Value(now),
        conflictStrategy: Value(conflictStrategy?.value),
      ),
    );
    return id;
  }
}
