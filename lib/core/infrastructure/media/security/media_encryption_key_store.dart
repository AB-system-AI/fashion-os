import 'dart:convert';
import 'dart:math';

import 'package:fashion_pos_enterprise/core/security/secure_storage_service.dart';

/// Persists per-device media encryption keys in secure storage.
class MediaEncryptionKeyStore {
  MediaEncryptionKeyStore({SecureStorageService? storage})
      : _storage = storage ?? SecureStorageService();

  static const _storageKey = 'media_encryption_key_v1';
  static String? _cachedKey;

  final SecureStorageService _storage;

  static String? get cachedKey => _cachedKey;

  Future<String> loadOrCreate() async {
    if (_cachedKey != null && _cachedKey!.length >= 32) return _cachedKey!;

    final existing = await _storage.read(_storageKey);
    if (existing != null && existing.length >= 32) {
      _cachedKey = existing;
      return existing;
    }

    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final key = base64Url.encode(bytes);
    await _storage.write(_storageKey, key);
    _cachedKey = key;
    return key;
  }

  /// Test-only helper — never use in production bootstrap.
  static void seedForTests(String key) {
    if (key.length < 32) {
      throw ArgumentError('Test media key must be at least 32 characters');
    }
    _cachedKey = key;
  }

  static void clearCache() => _cachedKey = null;
}
