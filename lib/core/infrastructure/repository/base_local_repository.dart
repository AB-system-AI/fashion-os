import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:uuid/uuid.dart';

/// Generic repository contract for all feature modules.
abstract class IRepository<T extends SyncableEntity> {
  Future<T?> getById(String id, {String? tenantId});
  Future<PaginatedResult<T>> getPage(RepositoryQuery query);
  Stream<List<T>> watch(RepositoryQuery query);
  Future<T> create(T entity);
  Future<T> update(T entity);
  Future<void> delete(String id, {String? tenantId});
  Future<void> softDelete(String id, {String? tenantId});
  Future<void> restore(String id, {String? tenantId});
  Future<List<T>> search(String query, {RepositoryQuery? base});
}

/// Base local repository with offline cache, sync queue, and soft-delete support.
abstract class BaseLocalRepository<T extends SyncableEntity> implements IRepository<T> {
  BaseLocalRepository({
    required AppDatabase database,
    required String entityType,
    required SyncQueueWriter syncQueue,
    Uuid? uuid,
  })  : _db = database,
        _entityType = entityType,
        _syncQueue = syncQueue,
        _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final String _entityType;
  final SyncQueueWriter _syncQueue;
  final Uuid _uuid;

  T mapFromLocalRecord(LocalRecord record);
  LocalRecord mapToLocalRecord(T entity);

  @override
  Future<T?> getById(String id, {String? tenantId}) async {
    final record = await _db.syncableRecordDao.getById(id, tenantId: tenantId);
    return record == null ? null : mapFromLocalRecord(record);
  }

  @override
  Future<PaginatedResult<T>> getPage(RepositoryQuery query) async {
    final effective = _withEntityType(query);
    final items = await _db.syncableRecordDao.getPage(effective);
    final total = await _db.syncableRecordDao.count(effective);
    return PaginatedResult(
      items: items.map(mapFromLocalRecord).toList(),
      page: query.page,
      pageSize: query.pageSize,
      totalCount: total,
      hasMore: query.offset + items.length < total,
    );
  }

  @override
  Stream<List<T>> watch(RepositoryQuery query) {
    return _db.syncableRecordDao
        .watchPage(_withEntityType(query))
        .map((records) => records.map(mapFromLocalRecord).toList());
  }

  @override
  Future<T> create(T entity) async {
    final now = DateTime.now().toUtc();
    final record = mapToLocalRecord(entity).copyWith(
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    await _persist(record, SyncOperation.create);
    return mapFromLocalRecord(record);
  }

  @override
  Future<T> update(T entity) async {
    final now = DateTime.now().toUtc();
    final record = mapToLocalRecord(entity).copyWith(
      version: entity.version + 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    await _persist(record, SyncOperation.update);
    return mapFromLocalRecord(record);
  }

  @override
  Future<void> delete(String id, {String? tenantId}) async {
    await softDelete(id, tenantId: tenantId);
  }

  @override
  Future<void> softDelete(String id, {String? tenantId}) async {
    final now = DateTime.now().toUtc();
    final resolvedTenant = tenantId ?? await _tenantIdFor(id);
    await _db.transaction(() async {
      await _db.syncableRecordDao.softDelete(id, now, tenantId: tenantId);
      await _syncQueue.enqueueInTransaction(
        tenantId: resolvedTenant,
        entityType: _entityType,
        entityId: id,
        operation: SyncOperation.delete,
        payload: {'id': id, 'deleted_at': now.toIso8601String()},
      );
    });
  }

  @override
  Future<void> restore(String id, {String? tenantId}) async {
    final now = DateTime.now().toUtc();
    final resolvedTenant = tenantId ?? await _tenantIdFor(id);
    await _db.transaction(() async {
      await _db.syncableRecordDao.restore(id, now, tenantId: tenantId);
      await _syncQueue.enqueueInTransaction(
        tenantId: resolvedTenant,
        entityType: _entityType,
        entityId: id,
        operation: SyncOperation.restore,
        payload: {'id': id, 'deleted_at': null},
      );
    });
  }

  @override
  Future<List<T>> search(String query, {RepositoryQuery? base}) async {
    final effective = _withEntityType(base ?? const RepositoryQuery());
    if (effective.tenantId == null) return [];
    final ftsQuery = query
        .trim()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .map((t) => '"${t.replaceAll('"', '""')}"*')
        .join(' ');
    if (ftsQuery.isEmpty) {
      final page = await getPage(effective);
      return page.items;
    }
    final records = await _db.syncableRecordDao.searchFts(
      tenantId: effective.tenantId!,
      entityType: _entityType,
      ftsQuery: ftsQuery,
      limit: effective.pageSize,
    );
    return records.map(mapFromLocalRecord).toList();
  }

  Future<void> _persist(LocalRecord record, SyncOperation operation) async {
    await _db.transaction(() async {
      await _db.syncableRecordDao.insertRecord(
        SyncableRecordsCompanion.insert(
          id: record.id,
          tenantId: record.tenantId,
          entityType: _entityType,
          storeId: Value(record.storeId),
          payload: jsonEncode(record.payload),
          version: Value(record.version),
          createdAt: record.createdAt,
          updatedAt: record.updatedAt,
          deletedAt: Value(record.deletedAt),
          syncStatus: Value(record.syncStatus.value),
          isDirty: Value(record.isDirty),
          searchName: Value(record.searchName),
          searchSku: Value(record.searchSku),
          searchBarcode: Value(record.searchBarcode),
        ),
      );
      await _syncQueue.enqueueInTransaction(
        tenantId: record.tenantId,
        entityType: _entityType,
        entityId: record.id,
        operation: operation,
        payload: record.payload,
        clientVersion: record.version,
      );
    });
  }

  RepositoryQuery _withEntityType(RepositoryQuery query) {
    return RepositoryQuery(
      page: query.page,
      pageSize: query.pageSize,
      sortBy: query.sortBy,
      sortDescending: query.sortDescending,
      searchTerm: query.searchTerm,
      tenantId: query.tenantId,
      entityType: _entityType,
      storeId: query.storeId,
      syncStatus: query.syncStatus,
      onlyDirty: query.onlyDirty,
      includeDeleted: query.includeDeleted,
      filters: query.filters,
    );
  }

  Future<String> _tenantIdFor(String id) async {
    final record = await _db.syncableRecordDao.getById(id);
    return record?.tenantId ?? '';
  }
}
