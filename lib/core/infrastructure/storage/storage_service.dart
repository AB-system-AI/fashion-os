import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/storage/storage_models.dart';

/// Stored file metadata.
class StoredFile extends Equatable {
  const StoredFile({
    required this.path,
    required this.url,
    required this.mimeType,
    required this.sizeBytes,
    this.bucket,
    this.checksum,
  });

  final String path;
  final String url;
  final String mimeType;
  final int sizeBytes;
  final String? bucket;
  final String? checksum;

  @override
  List<Object?> get props => [path, url, mimeType, sizeBytes];
}

/// Storage location target.
enum StorageTarget { local, supabase, s3 }

/// Contract for file/image/receipt/document/backup storage backends.
abstract class StorageAdapter {
  StorageTarget get target;

  Future<StoredFile> upload({
    required String path,
    required Uint8List bytes,
    required String mimeType,
    Map<String, String>? metadata,
  });

  Future<Uint8List> download(String path);

  Future<void> delete(String path);

  Future<String> getPublicUrl(String path);

  Future<bool> exists(String path);
}

/// Coordinates storage adapters with fallback ordering.
class StorageService {
  StorageService({required List<StorageAdapter> adapters}) : _adapters = adapters;

  final List<StorageAdapter> _adapters;

  StorageAdapter? adapterFor(StorageTarget target) {
    for (final adapter in _adapters) {
      if (adapter.target == target) return adapter;
    }
    return null;
  }

  Future<StoredFile> upload({
    required StorageTarget target,
    required String path,
    required Uint8List bytes,
    required String mimeType,
    Map<String, String>? metadata,
  }) async {
    final adapter = adapterFor(target);
    if (adapter == null) throw UnsupportedError('No adapter for $target');
    return adapter.upload(path: path, bytes: bytes, mimeType: mimeType, metadata: metadata);
  }
}
