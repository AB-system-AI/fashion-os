import 'dart:typed_data';

import 'package:fashion_pos_enterprise/core/infrastructure/cache/memory_cache.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/security/media_security_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/storage/local_media_storage.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

/// LRU memory + disk media cache with validation and prefetch.
class MediaCacheManager {
  MediaCacheManager({
    required MemoryCache<String, Uint8List> memoryCache,
    required LocalMediaStorage localStorage,
    required MediaSecurityService security,
    this.memoryTtl = const Duration(hours: 1),
    this.thumbnailTtl = const Duration(hours: 6),
  })  : _memory = memoryCache,
        _local = localStorage,
        _security = security;

  final MemoryCache<String, Uint8List> _memory;
  final LocalMediaStorage _local;
  final MediaSecurityService _security;
  final Duration memoryTtl;
  final Duration thumbnailTtl;

  Future<Uint8List?> getBytes(MediaAsset asset) async {
    final key = _cacheKey(asset);
    final cached = _memory.get(key);
    if (cached != null) return cached;

    if (asset.localPath == null) return null;
    final result = await _local.read(asset.localPath!);
    if (result.isFailure) return null;

    final bytes = (result as Success<Uint8List>).data;
    if (_security.validateChecksum(bytes, asset.checksum).isFailure) {
      await _local.delete(asset.localPath!);
      return null;
    }

    _memory.set(key, bytes, ttl: asset.variant == MediaVariant.thumbnail ? thumbnailTtl : memoryTtl, byteSize: bytes.length);
    return bytes;
  }

  Future<void> putBytes(MediaAsset asset, Uint8List bytes) async {
    _memory.set(_cacheKey(asset), bytes, ttl: memoryTtl, byteSize: bytes.length);
  }

  Future<void> prefetch(List<MediaAsset> assets) async {
    for (final asset in assets) {
      if (_memory.get(_cacheKey(asset)) != null) continue;
      await getBytes(asset);
    }
  }

  void evict(String assetId, {MediaVariant variant = MediaVariant.original}) {
    _memory.remove(_key(assetId, variant));
  }

  void clearMemory() => _memory.clear();

  String _cacheKey(MediaAsset asset) => _key(asset.id, asset.variant);

  String _key(String assetId, MediaVariant variant) => '$assetId:${variant.name}';
}
