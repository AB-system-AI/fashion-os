import 'dart:async';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/contracts/remote_storage_provider.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/indexing/media_index_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/storage/local_media_storage.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

/// Priority download queue with resume, cancel, retry, and offline availability.
class DownloadEngine {
  DownloadEngine({
    required Map<StorageBackend, RemoteStorageProvider> providers,
    required LocalMediaStorage localStorage,
    required MediaIndexRepository index,
    Uuid? uuid,
  })  : _providers = providers,
        _local = localStorage,
        _index = index,
        _uuid = uuid ?? const Uuid();

  final Map<StorageBackend, RemoteStorageProvider> _providers;
  final LocalMediaStorage _local;
  final MediaIndexRepository _index;
  final Uuid _uuid;

  final List<DownloadJob> _queue = [];
  final Map<String, StreamController<DownloadProgress>> _progressControllers = {};
  bool _processing = false;

  Stream<DownloadProgress> progressStream(String jobId) {
    return _progressControllers.putIfAbsent(jobId, () => StreamController<DownloadProgress>.broadcast()).stream;
  }

  Future<Result<DownloadJob>> enqueue(DownloadJob job) async {
    _queue.add(job);
    _queue.sort((a, b) => b.priority.compareTo(a.priority));
    _emit(job, DownloadStatus.queued);
    if (!_processing) unawaited(_processQueue());
    return Success(job);
  }

  Future<Result<void>> cancel(String jobId) async {
    final index = _queue.indexWhere((j) => j.id == jobId);
    if (index < 0) {
      return const Error(ValidationFailure(message: 'Download job not found', code: 'job_not_found'));
    }
    final job = _queue[index].copyWith(status: DownloadStatus.cancelled);
    _queue[index] = job;
    _emit(job, DownloadStatus.cancelled);
    _queue.removeAt(index);
    return const Success(null);
  }

  Future<Result<MediaAsset>> downloadAsset(MediaAsset asset, {int priority = 0}) async {
    if (asset.isOfflineAvailable && asset.localPath != null) {
      return Success(asset);
    }
    if (asset.remotePath == null || asset.remoteBucket == null) {
      return const Error(ValidationFailure(message: 'Asset has no remote location', code: 'no_remote'));
    }

    final job = DownloadJob(
      id: _uuid.v4(),
      assetId: asset.id,
      tenantId: asset.tenantId,
      remoteBucket: asset.remoteBucket!,
      remotePath: asset.remotePath!,
      backend: asset.storageBackend,
      status: DownloadStatus.queued,
      priority: priority,
      createdAt: DateTime.now().toUtc(),
      totalBytes: asset.sizeBytes,
    );
    await enqueue(job);
    return Success(asset);
  }

  Future<Result<MediaAsset>> batchDownload(List<MediaAsset> assets, {int priority = 0}) async {
    for (final asset in assets) {
      await downloadAsset(asset, priority: priority);
    }
    return Success(assets.first);
  }

  Future<void> _processQueue() async {
    if (_processing) return;
    _processing = true;
    try {
      while (_queue.isNotEmpty) {
        final job = _queue.firstWhere(
          (j) => j.status == DownloadStatus.queued || j.status == DownloadStatus.failed,
          orElse: () => _queue.first,
        );
        if (job.status == DownloadStatus.cancelled) {
          _queue.remove(job);
          continue;
        }
        await _executeDownload(job);
        _queue.removeWhere((j) => j.id == job.id && j.status == DownloadStatus.completed);
      }
    } finally {
      _processing = false;
    }
  }

  Future<void> _executeDownload(DownloadJob job) async {
    final provider = _providers[job.backend];
    if (provider == null) {
      _failJob(job, 'No provider for ${job.backend.name}');
      return;
    }

    var active = job.copyWith(status: DownloadStatus.downloading);
    _replaceJob(active);

    final result = await provider.download(
      bucket: job.remoteBucket,
      path: job.remotePath,
      onProgress: (d, t) {
        active = active.copyWith(bytesDownloaded: d, totalBytes: t);
        _emit(active, DownloadStatus.downloading);
      },
    );

    if (result.isFailure) {
      _failJob(active, result.failureOrNull!.message);
      return;
    }

    final bytes = (result as Success<Uint8List>).data;
    final asset = await _index.getById(job.assetId);
    if (asset == null) {
      _failJob(active, 'Asset index missing');
      return;
    }

    final writeResult = await _local.write(
      tenantId: job.tenantId,
      assetId: asset.id,
      bytes: bytes,
    );
    if (writeResult.isFailure) {
      _failJob(active, writeResult.failureOrNull!.message);
      return;
    }

    final localPath = (writeResult as Success<String>).data;
    final updated = asset.copyWith(
      localPath: localPath,
      syncStatus: MediaSyncStatus.synced,
      sizeBytes: bytes.length,
    );
    await _index.save(updated);

    final completed = active.copyWith(status: DownloadStatus.completed, localPath: localPath, bytesDownloaded: bytes.length);
    _replaceJob(completed);
    _emit(completed, DownloadStatus.completed);
  }

  void _failJob(DownloadJob job, String message) {
    final failed = job.copyWith(status: DownloadStatus.failed, errorMessage: message);
    _replaceJob(failed);
    _emit(failed, DownloadStatus.failed, errorMessage: message);
  }

  void _replaceJob(DownloadJob job) {
    final index = _queue.indexWhere((j) => j.id == job.id);
    if (index >= 0) _queue[index] = job;
  }

  void _emit(DownloadJob job, DownloadStatus status, {String? errorMessage}) {
    _progressControllers[job.id]?.add(
      DownloadProgress(
        jobId: job.id,
        assetId: job.assetId,
        status: status,
        bytesDownloaded: job.bytesDownloaded,
        totalBytes: job.totalBytes,
        errorMessage: errorMessage,
      ),
    );
  }

  void dispose() {
    for (final c in _progressControllers.values) {
      c.close();
    }
    _progressControllers.clear();
  }
}
