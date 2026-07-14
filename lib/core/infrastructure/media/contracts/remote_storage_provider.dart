import 'dart:typed_data';

import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

/// Remote object storage contract — features must never call Supabase/S3 directly.
abstract class RemoteStorageProvider {
  StorageBackend get backend;

  Future<Result<RemoteStoredObject>> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String mimeType,
    Map<String, String>? metadata,
    void Function(int uploaded, int total)? onProgress,
  });

  Future<Result<RemoteStoredObject>> uploadChunk({
    required String bucket,
    required String path,
    required Uint8List chunk,
    required int chunkIndex,
    required int totalChunks,
    required String mimeType,
    Map<String, String>? metadata,
  });

  Future<Result<Uint8List>> download({
    required String bucket,
    required String path,
    void Function(int downloaded, int total)? onProgress,
  });

  Future<Result<void>> delete({required String bucket, required String path});

  Future<Result<bool>> exists({required String bucket, required String path});

  Future<Result<String>> getPublicUrl({required String bucket, required String path});

  Future<Result<SignedUrlResult>> getSignedUrl({
    required String bucket,
    required String path,
    required Duration expiration,
    MediaAccessPolicy policy = MediaAccessPolicy.tenantScoped,
  });
}

/// Optional custom storage provider registration hook.
abstract class CustomStorageProvider extends RemoteStorageProvider {
  @override
  StorageBackend get backend => StorageBackend.custom;

  String get providerId;
}
