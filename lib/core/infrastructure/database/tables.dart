import 'package:drift/drift.dart';

/// Outbound sync operation queue.
class SyncQueueItems extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  IntColumn get clientVersion => integer().withDefault(const Constant(1))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  TextColumn get conflictStrategy => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get scheduledAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Per-device incremental sync watermarks.
class SyncCheckpoints extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get deviceId => text()();
  TextColumn get entityType => text()();
  IntColumn get lastVersion => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSyncedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Append-only sync diagnostic log.
class SyncLogs extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text().nullable()();
  TextColumn get level => text()();
  TextColumn get message => text()();
  TextColumn get entityType => text().nullable()();
  TextColumn get entityId => text().nullable()();
  TextColumn get metadata => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Cached auth context for offline session validation.
class AuthCacheEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Tenant/store key-value settings cache.
class LocalSettings extends Table {
  TextColumn get tenantId => text()();
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {tenantId, key};
}

/// Local audit trail pending server sync.
class AuditLogEntries extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text().nullable()();
  TextColumn get storeId => text().nullable()();
  TextColumn get employeeId => text().nullable()();
  TextColumn get deviceId => text().nullable()();
  TextColumn get action => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text().nullable()();
  TextColumn get oldValue => text().nullable()();
  TextColumn get newValue => text().nullable()();
  TextColumn get metadata => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Offline license cache with grace period metadata.
class LicenseCacheEntries extends Table {
  TextColumn get tenantId => text()();
  TextColumn get licenseType => text()();
  TextColumn get status => text()();
  DateTimeColumn get validUntil => dateTime().nullable()();
  DateTimeColumn get lastValidatedAt => dateTime()();
  DateTimeColumn get gracePeriodEndsAt => dateTime().nullable()();
  TextColumn get payload => text().withDefault(const Constant('{}'))();

  @override
  Set<Column<Object>> get primaryKey => {tenantId};
}

/// Generic syncable local entity storage for all feature modules.
class SyncableRecords extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get entityType => text()();
  TextColumn get storeId => text().nullable()();
  TextColumn get payload => text()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  BoolColumn get isDirty => boolean().withDefault(const Constant(false))();
  TextColumn get searchName => text().nullable()();
  TextColumn get searchSku => text().nullable()();
  TextColumn get searchBarcode => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Local feature flag cache for offline evaluation.
class FeatureFlagEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  TextColumn get source => text().withDefault(const Constant('remote'))();
  DateTimeColumn get fetchedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Startup recovery checkpoints and POS state keys.
class AppRecoveryEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// Sync conflict audit trail for manual and automatic resolution.
class SyncConflictHistory extends Table {
  TextColumn get id => text()();
  TextColumn get tenantId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get clientPayload => text()();
  TextColumn get serverPayload => text()();
  IntColumn get clientVersion => integer()();
  IntColumn get serverVersion => integer()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
