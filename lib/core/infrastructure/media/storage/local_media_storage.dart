import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/security/media_security_service.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

/// Encrypted local media file storage with quota tracking.
class LocalMediaStorage {
  LocalMediaStorage({
    Directory? rootDirectory,
    required MediaSecurityService security,
    Future<Directory> Function()? rootResolver,
    this.defaultQuotaBytes = 512 * 1024 * 1024,
    this.encryptFiles = true,
  })  : _rootDirectory = rootDirectory,
        _rootResolver = rootResolver,
        _security = security;

  Directory? _rootDirectory;
  final Future<Directory> Function()? _rootResolver;
  final MediaSecurityService _security;
  final int defaultQuotaBytes;
  final bool encryptFiles;

  final Map<String, int> _tenantUsage = {};

  Future<Directory> get rootDirectory async {
    if (_rootDirectory != null) return _rootDirectory!;
    if (_rootResolver != null) {
      _rootDirectory = await _rootResolver!();
      if (!await _rootDirectory!.exists()) await _rootDirectory!.create(recursive: true);
      return _rootDirectory!;
    }
    throw StateError('LocalMediaStorage root directory not configured');
  }

  Future<Result<String>> write({
    required String tenantId,
    required String assetId,
    required Uint8List bytes,
    CacheTier tier = CacheTier.persistent,
  }) async {
    final quota = StorageQuota(
      usedBytes: _tenantUsage[tenantId] ?? await _calculateUsage(tenantId),
      limitBytes: defaultQuotaBytes,
      tenantId: tenantId,
    );
    if (quota.usedBytes + bytes.length > quota.limitBytes) {
      return const Error(
        ValidationFailure(message: 'Storage quota exceeded', code: 'quota_exceeded'),
      );
    }

    final root = await rootDirectory;
    final dir = _tierDirectory(root, tenantId, tier);
    if (!await dir.exists()) await dir.create(recursive: true);

    final path = p.join(dir.path, assetId);
    final payload = encryptFiles ? _security.encrypt(bytes) : bytes;
    await File(path).writeAsBytes(payload, flush: true);

    _tenantUsage[tenantId] = (quota.usedBytes + payload.length);
    return Success(path);
  }

  Future<Result<Uint8List>> read(String localPath) async {
    final file = File(localPath);
    if (!await file.exists()) {
      return const Error(CacheFailure(message: 'Local media file not found', code: 'file_not_found'));
    }
    final raw = await file.readAsBytes();
    if (!encryptFiles) return Success(raw);
    return _security.decrypt(raw);
  }

  Future<Result<void>> delete(String localPath, {String? tenantId}) async {
    final file = File(localPath);
    if (!await file.exists()) return const Success(null);
    final length = await file.length();
    await file.writeAsBytes(_security.secureDeletePayload(length));
    await file.delete();
    if (tenantId != null) {
      _tenantUsage[tenantId] = ((_tenantUsage[tenantId] ?? await _calculateUsage(tenantId)) - length).clamp(0, 1 << 62);
    }
    return const Success(null);
  }

  Future<StorageQuota> quotaFor(String tenantId) async {
    final used = await _calculateUsage(tenantId);
    _tenantUsage[tenantId] = used;
    return StorageQuota(usedBytes: used, limitBytes: defaultQuotaBytes, tenantId: tenantId);
  }

  Future<int> cleanupTemporary({Duration maxAge = const Duration(hours: 24)}) async {
    var deleted = 0;
    final root = await rootDirectory;
    final tempRoot = Directory(p.join(root.path, '_temp'));
    if (!await tempRoot.exists()) return 0;

    final cutoff = DateTime.now().subtract(maxAge);
    await for (final entity in tempRoot.list(recursive: true)) {
      if (entity is! File) continue;
      final stat = await entity.stat();
      if (stat.modified.isBefore(cutoff)) {
        await entity.delete();
        deleted++;
      }
    }
    return deleted;
  }

  Directory _tierDirectory(Directory root, String tenantId, CacheTier tier) {
    final tierName = switch (tier) {
      CacheTier.temporary => '_temp',
      CacheTier.disk => 'disk',
      CacheTier.memory => 'memory',
      CacheTier.persistent => 'persistent',
    };
    return Directory(p.join(root.path, tierName, tenantId));
  }

  Future<int> _calculateUsage(String tenantId) async {
    var total = 0;
    final root = await rootDirectory;
    for (final tier in [CacheTier.persistent, CacheTier.disk, CacheTier.temporary]) {
      final dir = _tierDirectory(root, tenantId, tier);
      if (!await dir.exists()) continue;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) total += await entity.length();
      }
    }
    return total;
  }
}
