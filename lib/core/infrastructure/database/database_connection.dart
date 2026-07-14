import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/tables.dart';
import 'package:fashion_pos_enterprise/core/security/secure_storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';

/// Opens an encrypted SQLCipher connection for Drift.
LazyDatabase openEncryptedConnection({
  required Future<String> Function() encryptionKeyProvider,
  String databaseName = 'fashion_pos_local.db',
}) {
  return LazyDatabase(() async {
    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
    }

    final documentsDir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(documentsDir.path, databaseName));

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    final key = await encryptionKeyProvider();

    return NativeDatabase.createInBackground(
      dbFile,
      setup: (rawDb) {
        rawDb.execute("PRAGMA key = '${key.replaceAll("'", "''")}';");
        rawDb.execute('PRAGMA foreign_keys = ON;');
        rawDb.execute('PRAGMA journal_mode = WAL;');
        rawDb.execute('PRAGMA synchronous = FULL;');
      },
      logStatements: kDebugMode,
    );
  });
}

/// Default encryption key provider using secure storage.
Future<String> defaultEncryptionKeyProvider() async {
  const storageKey = 'local_db_encryption_key_v1';
  final storage = SecureStorageService();
  final existing = await storage.read(storageKey);
  if (existing != null && existing.length >= 32) return existing;

  final random = Random.secure();
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  final key = base64Url.encode(bytes);
  await storage.write(storageKey, key);
  return key;
}
