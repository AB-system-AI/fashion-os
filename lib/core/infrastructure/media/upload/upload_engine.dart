import 'dart:async';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/contracts/remote_storage_provider.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/indexing/media_index_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/storage/local_media_storage.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/network/network_monitor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

/// Manages upload queue with chunking, resume, pause, cancel, retry, and progress.
class UploadEngine {
  UploadEngine({
    required Map<StorageBackend, RemoteStorageProvider> providers,
    required LocalMediaStorage localStorage,
    required MediaIndexRepository index,
    required NetworkMonitor networkMonitor,
    SyncQueueWriter? syncQueueWriter,
    Uuid? uuid,
  })  : _providers = providers,
        _local = localStorage,
        _index = index,
        _network = networkMonitor,
        _syncQueue = syncQueueWriter,
        _uuid = uuid ?? const Uuid();

  final Map<StorageBackend, RemoteStorageProvider> _providers;
  final LocalMediaStorage _local;
  final MediaIndexRepository _index;
  final NetworkMonitor _network;
  final SyncQueueWriter? _syncQueue;
  final Uuid _uuid;

  final List<UploadJob> _queue = [];
  final Map<String, StreamController<UploadProgress>> _progressControllers = {};
  bool _processing = false;

  Stream<UploadProgress> progressStream(String jobId) {
    return _progressControllers.putIfAbsent(jobId, () => StreamController<UploadProgress>.broadcast()).stream;
  }

  Future<Result<UploadJob>> enqueue(UploadJob job) async {
    _queue.add(job);
    _emit(job, UploadStatus.queued);
    if (!_processing) unawaited(_processQueue());
    return Success(job);
  }

  Future<Result<UploadJob>> pause(String jobId) async {
    final job = _findJob(jobId);
    if (job == null) {
      return const Error(ValidationFailure(message: 'Upload job not found', code: 'job_not_found'));
    }
    final updated = job.copyWith(status: UploadStatus.paused, pausedAt: DateTime.now().toUtc());
    _replaceJob(updated);
    _emit(updated, UploadStatus.paused);
    return Success(updated);
  }

  Future<Result<void>> cancel(String jobId) async {
    final job = _findJob(jobId);
    if (job == null) {
      return const Error(ValidationFailure(message: 'Upload job not found', code: 'job_not_found'));
    }
    final updated = job.copyWith(status: UploadStatus.cancelled);
    _replaceJob(updated);
    _emit(updated, UploadStatus.cancelled);
    _queue.removeWhere((j) => j.id == jobId);
    return const Success(null);
  }

  Future<Result<MediaAsset>> retry(String jobId) async {
    final job = _findJob(jobId);
    if (job == null || !job.canRetry) {
      return const Error(ValidationFailure(message: 'Upload cannot be retried', code: 'retry_failed'));
    }
    final updated = job.copyWith(
      status: UploadStatus.queued,
      retryCount: job.retryCount + 1,
      errorMessage: null,
    );
    _replaceJob(updated);
    if (!_processing) unawaited(_processQueue());
    final asset = await _index.getById(job.assetId);
    if (asset == null) {
      return const Error(ValidationFailure(message: 'Asset not found', code: 'asset_not_found'));
    }
    return Success(asset);
  }

  List<UploadJob> get pendingJobs => List.unmodifiable(_queue);

  Future<void> processOfflineQueue() => _processQueue();

  Future<void> _processQueue() async {
    if (_processing) return;
    _processing = true;
    try {
      final network = await _network.currentState;
      if (!network.isOnline) return;

      final pending = _queue.where((j) => j.status == UploadStatus.queued || j.status == UploadStatus.failed).toList();
      for (final job in pending) {
        if (job.status == UploadStatus.paused || job.status == UploadStatus.cancelled) continue;
        await _executeUpload(job);
        if (job.status == UploadStatus.completed) {
          _queue.removeWhere((j) => j.id == job.id);
        }
      }
    } finally {
      _processing = false;
    }
  }

  Future<void> _executeUpload(UploadJob job) async {
    final provider = _providers[job.backend];
    if (provider == null) {
      _failJob(job, 'No storage provider for ${job.backend.name}');
      return;
    }

    final readResult = await _local.read(job.localPath);
    if (readResult.isFailure) {
      _failJob(job, readResult.failureOrNull!.message);
      return;
    }
    final bytes = (readResult as Success<Uint8List>).data;

    var active = job.copyWith(status: UploadStatus.uploading);
    _replaceJob(active);
    _emit(active, UploadStatus.uploading);

    final startOffset = active.bytesUploaded;
    final payload = startOffset > 0 ? Uint8List.sublistView(bytes, startOffset) : bytes;

    final result = await provider.upload(
      bucket: job.remoteBucket,
      path: job.remotePath,
      bytes: payload,
      mimeType: job.mimeType,
      onProgress: (uploaded, total) {
        final absolute = startOffset + uploaded;
        active = active.copyWith(bytesUploaded: absolute);
        _replaceJob(active);
        _emitProgress(active, absolute, bytes.length);
      },
    );

    if (result.isFailure) {
      _failJob(active, result.failureOrNull!.message);
      return;
    }

    final asset = await _index.getById(job.assetId);
    if (asset != null) {
      final synced = asset.copyWith(
        syncStatus: MediaSyncStatus.synced,
        uploadedAt: DateTime.now().toUtc(),
        remotePath: job.remotePath,
        remoteBucket: job.remoteBucket,
        storageBackend: job.backend,
      );
      await _index.save(synced);
      await _syncQueue?.enqueue(
        tenantId: job.tenantId,
        entityType: MediaIndexRepository.entityType,
        entityId: asset.id,
        operation: SyncOperation.update,
        payload: synced.toJson(),
      );
    }

    final completed = active.copyWith(status: UploadStatus.completed, bytesUploaded: bytes.length);
    _replaceJob(completed);
    _emit(completed, UploadStatus.completed);
  }

  void _failJob(UploadJob job, String message) {
    final failed = job.copyWith(status: UploadStatus.failed, errorMessage: message);
    _replaceJob(failed);
    _emit(failed, UploadStatus.failed, errorMessage: message);
  }

  UploadJob? _findJob(String jobId) {
    try {
      return _queue.firstWhere((j) => j.id == jobId);
    } catch (_) {
      return null;
    }
  }

  void _replaceJob(UploadJob job) {
    final index = _queue.indexWhere((j) => j.id == job.id);
    if (index >= 0) _queue[index] = job;
  }

  void _emit(UploadJob job, UploadStatus status, {String? errorMessage}) {
    _progressControllers[job.id]?.add(
      UploadProgress(
        jobId: job.id,
        assetId: job.assetId,
        status: status,
        bytesUploaded: job.bytesUploaded,
        totalBytes: job.totalBytes,
        errorMessage: errorMessage,
      ),
    );
  }

  void _emitProgress(UploadJob job, int uploaded, int total) {
    _emit(job, UploadStatus.uploading);
  }

  String createJobId() => _uuid.v4();

  void dispose() {
    for (final controller in _progressControllers.values) {
      controller.close();
    }
    _progressControllers.clear();
  }
}
