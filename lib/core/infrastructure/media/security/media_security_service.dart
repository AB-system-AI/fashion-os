import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

/// Media security: checksums, encryption, secure delete, signed URL validation.
class MediaSecurityService {
  MediaSecurityService({required String encryptionKey}) : _key = _requireKey(encryptionKey);

  final enc.Key _key;

  static enc.Key _requireKey(String provided) {
    if (provided.length < 32) {
      throw StateError('Media encryption key unavailable — bootstrap media initializer first');
    }
    return enc.Key.fromUtf8(provided.substring(0, 32));
  }

  String checksum(Uint8List bytes) => sha256.convert(bytes).toString();

  Result<void> validateChecksum(Uint8List bytes, String expected) {
    final actual = checksum(bytes);
    if (actual != expected) {
      return const Error(ValidationFailure(message: 'Checksum mismatch', code: 'checksum_invalid'));
    }
    return const Success(null);
  }

  Uint8List encrypt(Uint8List plain) {
    final iv = enc.IV.fromSecureRandom(16);
    final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(plain, iv: iv);
    final payload = Uint8List(iv.bytes.length + encrypted.bytes.length);
    payload.setRange(0, iv.bytes.length, iv.bytes);
    payload.setRange(iv.bytes.length, payload.length, encrypted.bytes);
    return payload;
  }

  Result<Uint8List> decrypt(Uint8List payload) {
    if (payload.length < 17) {
      return const Error(ValidationFailure(message: 'Invalid encrypted payload', code: 'decrypt_failed'));
    }
    try {
      final iv = enc.IV(payload.sublist(0, 16));
      final cipher = payload.sublist(16);
      final encrypter = enc.Encrypter(enc.AES(_key, mode: enc.AESMode.cbc));
      final decrypted = encrypter.decryptBytes(enc.Encrypted(cipher), iv: iv);
      return Success(Uint8List.fromList(decrypted));
    } catch (e) {
      return Error(ValidationFailure(message: 'Decryption failed: $e', code: 'decrypt_failed'));
    }
  }

  Uint8List secureDeletePayload(int sizeBytes) {
    return Uint8List(sizeBytes);
  }

  bool isSignedUrlValid(SignedUrlResult signed, {MediaAccessPolicy policy = MediaAccessPolicy.tenantScoped}) {
    if (!signed.isExpired) return true;
    return policy == MediaAccessPolicy.publicRead;
  }

  String encodeAccessMetadata(Map<String, dynamic> metadata) => jsonEncode(metadata);
}
