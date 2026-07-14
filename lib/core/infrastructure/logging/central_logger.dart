import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Log output sink contract.
abstract class LogSink {
  Future<void> write(LogRecord record);
  Future<void> flush();
  Future<void> dispose();
}

/// Structured log record.
class LogRecord {
  const LogRecord({
    required this.level,
    required this.message,
    required this.timestamp,
    this.error,
    this.stackTrace,
    this.metadata = const {},
  });

  final String level;
  final String message;
  final DateTime timestamp;
  final Object? error;
  final StackTrace? stackTrace;
  final Map<String, dynamic> metadata;
}

/// Console log sink.
class ConsoleLogSink implements LogSink {
  @override
  Future<void> write(LogRecord record) async {
    final buffer = StringBuffer('[${record.level}] ${record.message}');
    if (record.error != null) buffer.write(' | ${record.error}');
    // ignore: avoid_print
    print(buffer.toString());
  }

  @override
  Future<void> flush() async {}

  @override
  Future<void> dispose() async {}
}

/// Rotating file log sink.
class FileLogSink implements LogSink {
  FileLogSink({this.maxFileSizeBytes = 5 * 1024 * 1024});

  final int maxFileSizeBytes;
  IOSink? _sink;
  File? _file;

  Future<void> _ensureOpen() async {
    if (_sink != null) return;
    final dir = await getApplicationDocumentsDirectory();
    final logsDir = Directory(p.join(dir.path, 'logs'));
    if (!await logsDir.exists()) await logsDir.create(recursive: true);
    _file = File(p.join(logsDir.path, 'app.log'));
    _sink = _file!.openWrite(mode: FileMode.append);
  }

  @override
  Future<void> write(LogRecord record) async {
    await _ensureOpen();
    final line = jsonEncode({
      'level': record.level,
      'message': record.message,
      'timestamp': record.timestamp.toIso8601String(),
      'error': record.error?.toString(),
      'metadata': record.metadata,
    });
    _sink?.writeln(line);
    if (_file != null && await _file!.length() > maxFileSizeBytes) {
      await _sink?.flush();
      await _sink?.close();
      _sink = null;
      final rotated = File('${_file!.path}.${DateTime.now().millisecondsSinceEpoch}');
      await _file!.rename(rotated.path);
    }
  }

  @override
  Future<void> flush() async => _sink?.flush();

  @override
  Future<void> dispose() async {
    await _sink?.flush();
    await _sink?.close();
    _sink = null;
  }
}

/// Remote log sink — batches to sync log table for server ingestion.
class RemoteLogSink implements LogSink {
  RemoteLogSink(this._database);

  final AppDatabase _database;
  final _buffer = <LogRecord>[];
  Timer? _flushTimer;

  void start({Duration interval = const Duration(seconds: 30)}) {
    _flushTimer = Timer.periodic(interval, (_) => flush());
  }

  @override
  Future<void> write(LogRecord record) async {
    _buffer.add(record);
    if (_buffer.length >= 20) await flush();
  }

  @override
  Future<void> flush() async {
    if (_buffer.isEmpty) return;
    final batch = List<LogRecord>.from(_buffer);
    _buffer.clear();
    for (final record in batch) {
      await _database.syncLogDao.append(
        SyncLogsCompanion.insert(
          id: '${record.timestamp.microsecondsSinceEpoch}',
          level: record.level,
          message: record.message,
          metadata: Value(jsonEncode({
            'error': record.error?.toString(),
            'metadata': record.metadata,
          })),
          createdAt: record.timestamp,
        ),
      );
    }
  }

  @override
  Future<void> dispose() async {
    _flushTimer?.cancel();
    await flush();
  }
}

/// Central logging framework with multiple sinks.
class CentralLogger {
  CentralLogger(this._sinks);

  final List<LogSink> _sinks;

  Future<void> log(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic> metadata = const {},
  }) async {
    final record = LogRecord(
      level: level,
      message: message,
      timestamp: DateTime.now().toUtc(),
      error: error,
      stackTrace: stackTrace,
      metadata: metadata,
    );
    for (final sink in _sinks) {
      try {
        await sink.write(record);
      } catch (e, st) {
        AppLogger.error('Log sink failed', e, st);
      }
    }
  }

  Future<void> debug(String message, [Map<String, dynamic>? metadata]) =>
      log('debug', message, metadata: metadata ?? {});

  Future<void> info(String message, [Map<String, dynamic>? metadata]) =>
      log('info', message, metadata: metadata ?? {});

  Future<void> warning(String message, {Object? error, Map<String, dynamic>? metadata}) =>
      log('warning', message, error: error, metadata: metadata ?? {});

  Future<void> error(String message, Object error, [StackTrace? stackTrace]) =>
      log('error', message, error: error, stackTrace: stackTrace);

  Future<void> fatal(String message, Object error, [StackTrace? stackTrace]) =>
      log('fatal', message, error: error, stackTrace: stackTrace);

  Future<void> dispose() async {
    for (final sink in _sinks) {
      await sink.dispose();
    }
  }
}
