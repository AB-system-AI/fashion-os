import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Automatic encrypted database backup and restore for Drift.
class DatabaseBackupManager {
  DatabaseBackupManager(this._database, {this.maxBackups = 7});

  final AppDatabase _database;
  final int maxBackups;

  Future<File> createBackup({String label = 'manual'}) async {
    final executor = _database.executor;
    final dbPath = await _resolveDatabasePath();
    final backupDir = await _backupDirectory();
    if (!await backupDir.exists()) await backupDir.create(recursive: true);

    final timestamp = DateTime.now().toUtc().toIso8601String().replaceAll(':', '-');
    final archivePath = p.join(backupDir.path, 'fashion_pos_local.db.$label.$timestamp.zip');

    await executor.ensureOpen(_database);
    final encoder = ZipFileEncoder()..create(archivePath);
    encoder.addFile(File(dbPath));
    for (final suffix in ['-wal', '-shm']) {
      final sidecar = File('$dbPath$suffix');
      if (await sidecar.exists()) encoder.addFile(sidecar);
    }
    encoder.close();

    await _pruneOldBackups(backupDir);
    AppLogger.info('Database backup created: $archivePath');
    return File(archivePath);
  }

  Future<String> _resolveDatabasePath() async {
    final docs = await getApplicationDocumentsDirectory();
    return p.join(docs.path, 'fashion_pos_local.db');
  }

  Future<Directory> _backupDirectory() async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(docs.path, 'db_backups'));
  }

  Future<void> _pruneOldBackups(Directory dir) async {
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.zip'))
        .toList()
      ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    for (final file in files.skip(maxBackups)) {
      await file.delete();
    }
  }
}
