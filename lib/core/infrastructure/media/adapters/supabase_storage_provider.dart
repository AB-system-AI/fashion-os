import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/contracts/remote_storage_provider.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

/// Supabase Storage implementation — isolated from feature modules.
class SupabaseStorageProvider implements RemoteStorageProvider {
  SupabaseStorageProvider({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  StorageBackend get backend => StorageBackend.supabase;

  @override
  Future<Result<RemoteStoredObject>> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String mimeType,
    Map<String, String>? metadata,
    void Function(int uploaded, int total)? onProgress,
  }) async {
    try {
      onProgress?.call(0, bytes.length);
      await _client.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: true, metadata: metadata),
          );
      onProgress?.call(bytes.length, bytes.length);
      final url = _client.storage.from(bucket).getPublicUrl(path);
      return Success(
        RemoteStoredObject(
          bucket: bucket,
          path: path,
          url: url,
          sizeBytes: bytes.length,
          mimeType: mimeType,
          isPublic: true,
        ),
      );
    } catch (e) {
      return Error(ServerFailure(message: 'Supabase upload failed: $e', code: 'upload_failed'));
    }
  }

  @override
  Future<Result<RemoteStoredObject>> uploadChunk({
    required String bucket,
    required String path,
    required Uint8List chunk,
    required int chunkIndex,
    required int totalChunks,
    required String mimeType,
    Map<String, String>? metadata,
  }) async {
    final chunkPath = '$path.part$chunkIndex';
    return upload(
      bucket: bucket,
      path: chunkPath,
      bytes: chunk,
      mimeType: mimeType,
      metadata: {...?metadata, 'chunk_index': '$chunkIndex', 'total_chunks': '$totalChunks'},
    );
  }

  @override
  Future<Result<Uint8List>> download({
    required String bucket,
    required String path,
    void Function(int downloaded, int total)? onProgress,
  }) async {
    try {
      onProgress?.call(0, 1);
      final bytes = await _client.storage.from(bucket).download(path);
      onProgress?.call(bytes.length, bytes.length);
      return Success(Uint8List.fromList(bytes));
    } catch (e) {
      return Error(ServerFailure(message: 'Supabase download failed: $e', code: 'download_failed'));
    }
  }

  @override
  Future<Result<void>> delete({required String bucket, required String path}) async {
    try {
      await _client.storage.from(bucket).remove([path]);
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure(message: 'Supabase delete failed: $e', code: 'delete_failed'));
    }
  }

  @override
  Future<Result<bool>> exists({required String bucket, required String path}) async {
    try {
      final parts = path.split('/');
      final fileName = parts.removeLast();
      final folder = parts.join('/');
      final list = await _client.storage.from(bucket).list(path: folder);
      return Success(list.any((f) => f.name == fileName));
    } catch (_) {
      return const Success(false);
    }
  }

  @override
  Future<Result<String>> getPublicUrl({required String bucket, required String path}) async {
    return Success(_client.storage.from(bucket).getPublicUrl(path));
  }

  @override
  Future<Result<SignedUrlResult>> getSignedUrl({
    required String bucket,
    required String path,
    required Duration expiration,
    MediaAccessPolicy policy = MediaAccessPolicy.tenantScoped,
  }) async {
    try {
      final expiresIn = expiration.inSeconds;
      final url = await _client.storage.from(bucket).createSignedUrl(path, expiresIn);
      return Success(
        SignedUrlResult(
          url: url,
          expiresAt: DateTime.now().toUtc().add(expiration),
          policy: policy,
        ),
      );
    } catch (e) {
      return Error(ServerFailure(message: 'Signed URL failed: $e', code: 'signed_url_failed'));
    }
  }
}
