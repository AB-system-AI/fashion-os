import 'package:drift/drift.dart';
import 'package:drift/native.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/database_connection.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/tables.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';

part 'app_database.g.dart';
part 'daos/sync_queue_dao.dart';
part 'daos/sync_checkpoint_dao.dart';
part 'daos/sync_log_dao.dart';
part 'daos/syncable_record_dao.dart';
part 'daos/support_daos.dart';
part 'daos/sync_conflict_dao.dart';

@DriftDatabase(
  tables: [
    SyncQueueItems,
    SyncCheckpoints,
    SyncLogs,
    AuthCacheEntries,
    LocalSettings,
    AuditLogEntries,
    LicenseCacheEntries,
    SyncableRecords,
    FeatureFlagEntries,
    AppRecoveryEntries,
    SyncConflictHistory,
  ],
  daos: [
    SyncQueueDao,
    SyncCheckpointDao,
    SyncLogDao,
    SyncableRecordDao,
    SettingsDao,
    AuthCacheDao,
    AuditLogDao,
    LicenseCacheDao,
    FeatureFlagDao,
    RecoveryDao,
    SyncConflictDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  factory AppDatabase.encrypted({
    Future<String> Function()? encryptionKeyProvider,
  }) {
    return AppDatabase(
      openEncryptedConnection(
        encryptionKeyProvider: encryptionKeyProvider ?? defaultEncryptionKeyProvider,
      ),
    );
  }

  factory AppDatabase.inMemory() {
    return AppDatabase(NativeDatabase.memory());
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createIndexes(m);
          await _createFts(m);
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await _migrateToV2(m);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await customStatement('PRAGMA journal_mode = WAL');
          await customStatement('PRAGMA synchronous = FULL');
        },
      );

  Future<void> _migrateToV2(Migrator m) async {
    await m.createTable(syncConflictHistory);
    await customStatement('''
      CREATE TABLE IF NOT EXISTS local_settings_v2 (
        tenant_id TEXT NOT NULL,
        key TEXT NOT NULL,
        value TEXT NOT NULL,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (tenant_id, key)
      )
    ''');
    await customStatement('''
      INSERT OR REPLACE INTO local_settings_v2 (tenant_id, key, value, updated_at)
      SELECT tenant_id, key, value, updated_at FROM local_settings
    ''');
    await customStatement('DROP TABLE IF EXISTS local_settings');
    await customStatement('ALTER TABLE local_settings_v2 RENAME TO local_settings');
    await _createIndexes(m);
  }

  Future<void> _createIndexes(Migrator m) async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_queue_status ON sync_queue_items (status, scheduled_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_queue_entity ON sync_queue_items (entity_type, entity_id)',
    );
    await customStatement(
      'CREATE UNIQUE INDEX IF NOT EXISTS idx_sync_checkpoints_device_entity ON sync_checkpoints (device_id, entity_type)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_syncable_records_tenant ON syncable_records (tenant_id, entity_type)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_syncable_records_store ON syncable_records (tenant_id, entity_type, store_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_syncable_records_barcode ON syncable_records (tenant_id, search_barcode)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_syncable_records_updated ON syncable_records (tenant_id, updated_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_syncable_records_dirty ON syncable_records (tenant_id, entity_type, is_dirty)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_audit_unsynced ON audit_log_entries (synced, created_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_audit_entity ON audit_log_entries (entity_type, entity_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_logs_created ON sync_logs (created_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_local_settings_tenant_key ON local_settings (tenant_id, key)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sync_conflicts_entity ON sync_conflict_history (tenant_id, entity_type, entity_id)',
    );
  }

  Future<void> _createFts(Migrator m) async {
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS syncable_records_fts USING fts5(
        record_id UNINDEXED,
        tenant_id UNINDEXED,
        entity_type UNINDEXED,
        search_name,
        search_sku,
        search_barcode,
        tokenize='unicode61'
      )
    ''');
  }

  Future<void> runIntegrityCheck() async {
    final result = await customSelect('PRAGMA integrity_check').get();
    if (result.isEmpty || result.first.data.values.first != 'ok') {
      throw StateError('Database integrity check failed');
    }
  }
}
