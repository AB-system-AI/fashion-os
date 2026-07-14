import 'dart:convert';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/database_initializer.dart';

/// Disk-backed cache using local settings table.
class DiskCache {
  DiskCache({AppDatabase? database}) : _db = database;

  AppDatabase? _db;

  Future<AppDatabase> get _database async => _db ??= DatabaseInitializer.database;

  Future<String?> read(String key, {required String tenantId}) async {
    final db = await _database;
    return db.settingsDao.getValue(key: key, tenantId: tenantId);
  }

  Future<void> write(
    String key, {
    required String tenantId,
    required Map<String, dynamic> value,
    Duration? ttl,
  }) async {
    final db = await _database;
    final payload = jsonEncode({
      'value': value,
      'expires_at': ttl == null ? null : DateTime.now().toUtc().add(ttl).toIso8601String(),
    });
    await db.settingsDao.setValue(key: 'cache:$key', tenantId: tenantId, value: payload);
  }

  Future<Map<String, dynamic>?> readJson(String key, {required String tenantId}) async {
    final raw = await read('cache:$key', tenantId: tenantId);
    if (raw == null) return null;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final expires = decoded['expires_at'] as String?;
    if (expires != null && DateTime.parse(expires).isBefore(DateTime.now().toUtc())) {
      return null;
    }
    return decoded['value'] as Map<String, dynamic>?;
  }
}

/// Repository-level cache decorator keys.
class RepositoryCacheKeys {
  static String entity(String entityType, String id) => 'repo:$entityType:$id';
  static String page(String entityType, int page) => 'repo:$entityType:page:$page';
}
