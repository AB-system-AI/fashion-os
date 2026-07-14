import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/indexing/media_index_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/upload/upload_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/network/network_monitor.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';

/// Integrates media uploads with offline sync and conflict detection.
class MediaSyncIntegration {
  MediaSyncIntegration({
    required UploadEngine uploadEngine,
    required MediaIndexRepository index,
    required NetworkMonitor networkMonitor,
  })  : _upload = uploadEngine,
        _index = index,
        _network = networkMonitor;

  final UploadEngine _upload;
  final MediaIndexRepository _index;
  final NetworkMonitor _network;

  Future<void> syncPendingUploads(String tenantId) async {
    final network = await _network.currentState;
    if (!network.isOnline) return;

    final pending = await _index.listPendingUpload(tenantId);
    AppLogger.info('MediaSync: processing ${pending.length} pending uploads');
    await _upload.processOfflineQueue();
  }

  Future<bool> detectConflict(MediaAsset local, MediaAsset remote) async {
    if (local.checksum == remote.checksum) return false;
    if (local.uploadedAt != null &&
        remote.uploadedAt != null &&
        remote.uploadedAt!.isAfter(local.uploadedAt!)) {
      return true;
    }
    return local.syncStatus == MediaSyncStatus.conflict;
  }
}
