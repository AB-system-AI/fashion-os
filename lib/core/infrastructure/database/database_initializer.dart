import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/database_backup_manager.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';

/// Initializes, validates, and manages the encrypted Drift database lifecycle.
class DatabaseInitializer {
  DatabaseInitializer._();

  static AppDatabase? _database;
  static DatabaseBackupManager? _backupManager;

  static AppDatabase get database {
    final db = _database;
    if (db == null) {
      throw StateError('Database not initialized. Call DatabaseInitializer.initialize() first.');
    }
    return db;
  }

  static DatabaseBackupManager get backupManager {
    return _backupManager ??= DatabaseBackupManager(database);
  }

  static Future<AppDatabase> initialize() async {
    if (_database != null) return _database!;

    final db = AppDatabase.encrypted();
    await db.executor.ensureOpen(db);
    await db.runIntegrityCheck();
    _database = db;
    _backupManager = DatabaseBackupManager(db);

    AppLogger.info('Drift database initialized (schema v${db.schemaVersion})');
    return db;
  }

  static Future<void> close() async {
    await _database?.close();
    _database = null;
    _backupManager = null;
  }
}
