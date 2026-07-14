import 'package:drift/drift.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/tables.dart';

part of 'app_database.dart';

@DriftAccessor(tables: [LocalSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getValue({required String key, required String tenantId}) async {
    final row = await (select(localSettings)
          ..where((t) => t.key.equals(key))
          ..where((t) => t.tenantId.equals(tenantId))
          ..limit(1))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setValue({
    required String key,
    required String tenantId,
    required String value,
  }) {
    return into(localSettings).insert(
      LocalSettingsCompanion.insert(
        key: key,
        tenantId: tenantId,
        value: value,
        updatedAt: DateTime.now().toUtc(),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
}

@DriftAccessor(tables: [AuthCacheEntries])
class AuthCacheDao extends DatabaseAccessor<AppDatabase> with _$AuthCacheDaoMixin {
  AuthCacheDao(super.db);

  Future<String?> read(String key) async {
    final row = await (select(authCacheEntries)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> write(String key, String value) {
    return into(authCacheEntries).insert(
      AuthCacheEntriesCompanion.insert(
        key: key,
        value: value,
        updatedAt: DateTime.now().toUtc(),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> deleteKey(String key) {
    return (delete(authCacheEntries)..where((t) => t.key.equals(key))).go();
  }
}

@DriftAccessor(tables: [AuditLogEntries])
class AuditLogDao extends DatabaseAccessor<AppDatabase> with _$AuditLogDaoMixin {
  AuditLogDao(super.db);

  Future<void> append(AuditLogEntriesCompanion entry) {
    return into(auditLogEntries).insert(entry);
  }

  Future<List<AuditLogEntry>> getUnsynced({int limit = 100}) {
    return (select(auditLogEntries)
          ..where((t) => t.synced.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<void> markSynced(List<String> ids) {
    if (ids.isEmpty) return Future.value();
    return (update(auditLogEntries)..where((t) => t.id.isIn(ids))).write(
      const AuditLogEntriesCompanion(synced: Value(true)),
    );
  }

  Future<List<AuditLogEntry>> getByEntity({
    required String entityType,
    required String entityId,
    int limit = 100,
  }) {
    return (select(auditLogEntries)
          ..where((t) => t.entityType.equals(entityType))
          ..where((t) => t.entityId.equals(entityId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }
}

@DriftAccessor(tables: [LicenseCacheEntries])
class LicenseCacheDao extends DatabaseAccessor<AppDatabase> with _$LicenseCacheDaoMixin {
  LicenseCacheDao(super.db);

  Future<LicenseCacheEntry?> getByTenant(String tenantId) {
    return (select(licenseCacheEntries)..where((t) => t.tenantId.equals(tenantId)))
        .getSingleOrNull();
  }

  Future<void> upsert(LicenseCacheEntriesCompanion entry) {
    return into(licenseCacheEntries).insert(entry, mode: InsertMode.insertOrReplace);
  }
}

@DriftAccessor(tables: [FeatureFlagEntries])
class FeatureFlagDao extends DatabaseAccessor<AppDatabase> with _$FeatureFlagDaoMixin {
  FeatureFlagDao(super.db);

  Future<List<FeatureFlagEntry>> getAll() => select(featureFlagEntries).get();

  Future<void> upsert(FeatureFlagEntriesCompanion entry) {
    return into(featureFlagEntries).insert(entry, mode: InsertMode.insertOrReplace);
  }

  Future<void> clearExpired() {
    final now = DateTime.now().toUtc();
    return (delete(featureFlagEntries)..where((t) => t.expiresAt.isSmallerThanValue(now))).go();
  }
}

@DriftAccessor(tables: [AppRecoveryEntries])
class RecoveryDao extends DatabaseAccessor<AppDatabase> with _$RecoveryDaoMixin {
  RecoveryDao(super.db);

  Future<String?> read(String key) async {
    final row =
        await (select(appRecoveryEntries)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> write(String key, String value) {
    return into(appRecoveryEntries).insert(
      AppRecoveryEntriesCompanion.insert(
        key: key,
        value: value,
        updatedAt: DateTime.now().toUtc(),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
}
