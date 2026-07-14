import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/database_initializer.dart';

/// Backward-compatible facade for Drift [AppDatabase].
/// Prefer [DatabaseInitializer] or [appDatabaseProvider] in new code.
class LocalDatabase {
  LocalDatabase._();

  static Future<AppDatabase> get instance => DatabaseInitializer.initialize();

  static Future<AppDatabase> initialize() => DatabaseInitializer.initialize();

  static Future<void> close() => DatabaseInitializer.close();
}
