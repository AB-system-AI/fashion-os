import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/tables.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';

part of 'app_database.dart';

@DriftAccessor(tables: [SyncableRecords])
class SyncableRecordDao extends DatabaseAccessor<AppDatabase> with _$SyncableRecordDaoMixin {
  SyncableRecordDao(super.db);

  Future<LocalRecord?> getById(String id, {String? tenantId}) async {
    final q = select(syncableRecords)..where((t) => t.id.equals(id));
    if (tenantId != null) q.where((t) => t.tenantId.equals(tenantId));
    final row = await q.getSingleOrNull();
    return row == null ? null : _mapRow(row);
  }

  Future<LocalRecord?> getByBarcode({
    required String tenantId,
    required String barcode,
    required String entityType,
  }) async {
    final row = await (select(syncableRecords)
          ..where((t) => t.tenantId.equals(tenantId))
          ..where((t) => t.entityType.equals(entityType))
          ..where((t) => t.searchBarcode.equals(barcode))
          ..where((t) => t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _mapRow(row);
  }

  Future<List<LocalRecord>> getPage(RepositoryQuery query) async {
    final rows = await _buildQuery(query).get();
    return rows.map(_mapRow).toList();
  }

  Future<int> count(RepositoryQuery query) async {
    final count = syncableRecords.id.count();
    final q = _buildCountQuery(query)..addColumns([count]);
    final row = await q.getSingle();
    return row.read(count) ?? 0;
  }

  Stream<List<LocalRecord>> watchPage(RepositoryQuery query) {
    return _buildQuery(query).watch().map((rows) => rows.map(_mapRow).toList());
  }

  Future<void> insertRecord(SyncableRecordsCompanion companion) async {
    await into(syncableRecords).insert(companion, mode: InsertMode.insertOrReplace);
    await _syncFtsFromCompanion(companion);
  }

  Future<void> updateRecord(String id, SyncableRecordsCompanion companion, {String? tenantId}) async {
    final q = update(syncableRecords)..where((t) => t.id.equals(id));
    if (tenantId != null) q.where((t) => t.tenantId.equals(tenantId));
    await q.write(companion);
    final recordId = companion.id.present ? companion.id.value : id;
    if (!companion.deletedAt.present || companion.deletedAt.value == null) {
      await _syncFtsFromCompanion(companion, recordId: recordId);
    } else {
      await _deleteFts(recordId);
    }
  }

  Future<void> upsertFromRemote(SyncableRecordsCompanion companion) async {
    await into(syncableRecords).insert(companion, mode: InsertMode.insertOrReplace);
    await _syncFtsFromCompanion(companion);
  }

  Future<void> softDelete(String id, DateTime deletedAt, {String? tenantId}) async {
    final q = update(syncableRecords)..where((t) => t.id.equals(id));
    if (tenantId != null) q.where((t) => t.tenantId.equals(tenantId));
    await q.write(
      SyncableRecordsCompanion(
        deletedAt: Value(deletedAt),
        updatedAt: Value(deletedAt),
        isDirty: const Value(true),
        syncStatus: const Value('pending'),
      ),
    );
    await _deleteFts(id);
  }

  Future<void> restore(String id, DateTime updatedAt, {String? tenantId}) async {
    final q = update(syncableRecords)..where((t) => t.id.equals(id));
    if (tenantId != null) q.where((t) => t.tenantId.equals(tenantId));
    await q.write(
      SyncableRecordsCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(updatedAt),
        isDirty: const Value(true),
        syncStatus: const Value('pending'),
      ),
    );
    final record = await getById(id, tenantId: tenantId);
    if (record != null) {
      await _upsertFts(
        recordId: record.id,
        tenantId: record.tenantId,
        entityType: record.entityType,
        searchName: record.searchName,
        searchSku: record.searchSku,
        searchBarcode: record.searchBarcode,
      );
    }
  }

  Future<List<LocalRecord>> searchFts({
    required String tenantId,
    required String entityType,
    required String ftsQuery,
    int limit = 50,
  }) async {
    final results = await customSelect(
      '''
      SELECT r.*
      FROM syncable_records r
      JOIN syncable_records_fts fts ON fts.record_id = r.id
      WHERE syncable_records_fts MATCH ?
        AND fts.tenant_id = ?
        AND fts.entity_type = ?
        AND r.deleted_at IS NULL
      ORDER BY rank
      LIMIT ?
      ''',
      variables: [
        Variable<String>(ftsQuery),
        Variable<String>(tenantId),
        Variable<String>(entityType),
        Variable<int>(limit),
      ],
      readsFrom: {syncableRecords},
    ).get();

    return results.map((row) {
      return LocalRecord(
        id: row.read<String>('id'),
        tenantId: row.read<String>('tenant_id'),
        entityType: row.read<String>('entity_type'),
        storeId: row.readNullable<String>('store_id'),
        payload: jsonDecode(row.read<String>('payload')) as Map<String, dynamic>,
        version: row.read<int>('version'),
        createdAt: DateTime.parse(row.read<String>('created_at')),
        updatedAt: DateTime.parse(row.read<String>('updated_at')),
        deletedAt: row.readNullable<String>('deleted_at') != null
            ? DateTime.parse(row.read<String>('deleted_at'))
            : null,
        syncStatus: LocalSyncStatus.fromValue(row.read<String>('sync_status')),
        isDirty: row.read<bool>('is_dirty') == true,
        searchName: row.readNullable<String>('search_name'),
        searchSku: row.readNullable<String>('search_sku'),
        searchBarcode: row.readNullable<String>('search_barcode'),
      );
    }).toList();
  }

  Future<void> rebuildFtsIndex({String? tenantId, String? entityType}) async {
    if (tenantId == null && entityType == null) {
      await customStatement('DELETE FROM syncable_records_fts');
    }
    final query = select(syncableRecords)..where((t) => t.deletedAt.isNull());
    if (tenantId != null) query.where((t) => t.tenantId.equals(tenantId));
    if (entityType != null) query.where((t) => t.entityType.equals(entityType));
    final rows = await query.get();
    for (final row in rows) {
      await _upsertFts(
        recordId: row.id,
        tenantId: row.tenantId,
        entityType: row.entityType,
        searchName: row.searchName,
        searchSku: row.searchSku,
        searchBarcode: row.searchBarcode,
      );
    }
  }

  Future<void> _syncFtsFromCompanion(SyncableRecordsCompanion companion, {String? recordId}) async {
    final id = recordId ?? (companion.id.present ? companion.id.value : null);
    if (id == null) return;
    await _upsertFts(
      recordId: id,
      tenantId: companion.tenantId.present ? companion.tenantId.value : '',
      entityType: companion.entityType.present ? companion.entityType.value : '',
      searchName: companion.searchName.present ? companion.searchName.value : null,
      searchSku: companion.searchSku.present ? companion.searchSku.value : null,
      searchBarcode: companion.searchBarcode.present ? companion.searchBarcode.value : null,
    );
  }

  Future<void> _upsertFts({
    required String recordId,
    required String tenantId,
    required String entityType,
    String? searchName,
    String? searchSku,
    String? searchBarcode,
  }) async {
    await _deleteFts(recordId);
    await customStatement(
      '''
      INSERT INTO syncable_records_fts(
        record_id, tenant_id, entity_type, search_name, search_sku, search_barcode
      ) VALUES (?, ?, ?, ?, ?, ?)
      ''',
      [recordId, tenantId, entityType, searchName ?? '', searchSku ?? '', searchBarcode ?? ''],
    );
  }

  Future<void> _deleteFts(String recordId) async {
    await customStatement('DELETE FROM syncable_records_fts WHERE record_id = ?', [recordId]);
  }

  Selectable<SyncableRecord> _buildQuery(RepositoryQuery query) {
    final q = select(syncableRecords);
    if (!query.includeDeleted) q.where((t) => t.deletedAt.isNull());
    if (query.tenantId != null) q.where((t) => t.tenantId.equals(query.tenantId!));
    if (query.entityType != null) q.where((t) => t.entityType.equals(query.entityType!));
    if (query.storeId != null) q.where((t) => t.storeId.equals(query.storeId!));
    if (query.onlyDirty) q.where((t) => t.isDirty.equals(true));
    if (query.syncStatus != null) {
      q.where((t) => t.syncStatus.equals(query.syncStatus!.value));
    }
    for (final filter in query.filters.entries) {
      q.where((t) => t.payload.like('%${filter.key}%:${filter.value}%'));
    }
    if (query.searchTerm != null && query.searchTerm!.isNotEmpty) {
      final term = '%${query.searchTerm!.replaceAll('%', '')}%';
      q.where(
        (t) => t.searchName.like(term) | t.searchSku.like(term) | t.searchBarcode.like(term),
      );
    }
    final sortColumn = query.sortBy ?? 'updated_at';
    final ordering = query.sortDescending ? OrderingTerm.desc : OrderingTerm.asc;
    switch (sortColumn) {
      case 'created_at':
        q.orderBy([(t) => ordering(t.createdAt)]);
      case 'name':
        q.orderBy([(t) => ordering(t.searchName)]);
      case 'version':
        q.orderBy([(t) => ordering(t.version)]);
      default:
        q.orderBy([(t) => ordering(t.updatedAt)]);
    }
    q.limit(query.pageSize, offset: query.offset);
    return q;
  }

  JoinedSelectStatement<HasResultSet, dynamic> _buildCountQuery(RepositoryQuery query) {
    final q = selectOnly(syncableRecords);
    if (!query.includeDeleted) q.where(syncableRecords.deletedAt.isNull());
    if (query.tenantId != null) q.where(syncableRecords.tenantId.equals(query.tenantId!));
    if (query.entityType != null) q.where(syncableRecords.entityType.equals(query.entityType!));
    if (query.storeId != null) q.where(syncableRecords.storeId.equals(query.storeId!));
    if (query.onlyDirty) q.where(syncableRecords.isDirty.equals(true));
    if (query.syncStatus != null) {
      q.where(syncableRecords.syncStatus.equals(query.syncStatus!.value));
    }
    for (final filter in query.filters.entries) {
      q.where(syncableRecords.payload.like('%${filter.key}%:${filter.value}%'));
    }
    if (query.searchTerm != null && query.searchTerm!.isNotEmpty) {
      final term = '%${query.searchTerm!.replaceAll('%', '')}%';
      q.where(
        syncableRecords.searchName.like(term) |
            syncableRecords.searchSku.like(term) |
            syncableRecords.searchBarcode.like(term),
      );
    }
    return q;
  }

  LocalRecord _mapRow(SyncableRecord row) {
    return LocalRecord(
      id: row.id,
      tenantId: row.tenantId,
      entityType: row.entityType,
      storeId: row.storeId,
      payload: jsonDecode(row.payload) as Map<String, dynamic>,
      version: row.version,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
      syncStatus: LocalSyncStatus.fromValue(row.syncStatus),
      isDirty: row.isDirty,
      searchName: row.searchName,
      searchSku: row.searchSku,
      searchBarcode: row.searchBarcode,
    );
  }
}
