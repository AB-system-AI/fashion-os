import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/media/adapters/remote_storage_adapters.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';

void main() {
  group('LocalRemoteStorageProvider', () {
    late LocalRemoteStorageProvider provider;
    late Map<String, Uint8List> store;

    setUp(() {
      store = {};
      provider = LocalRemoteStorageProvider(store);
    });

    test('upload and download roundtrip', () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      final upload = await provider.upload(
        bucket: 'product-images',
        path: 'tenant/p1/img.webp',
        bytes: bytes,
        mimeType: 'image/webp',
      );
      expect(upload.isSuccess, isTrue);

      final download = await provider.download(bucket: 'product-images', path: 'tenant/p1/img.webp');
      expect((download as Success<Uint8List>).data, bytes);
    });

    test('delete removes object', () async {
      await provider.upload(
        bucket: 'b',
        path: 'p',
        bytes: Uint8List.fromList([1]),
        mimeType: 'image/png',
      );
      await provider.delete(bucket: 'b', path: 'p');
      final exists = await provider.exists(bucket: 'b', path: 'p');
      expect((exists as Success<bool>).data, isFalse);
    });
  });

  group('S3CompatibleStorageProvider', () {
    test('stores bytes when configured', () async {
      final store = <String, Uint8List>{};
      final provider = S3CompatibleStorageProvider(
        backend: StorageBackend.s3,
        endpoint: 'https://s3.example.com',
        region: 'us-east-1',
        accessKeyId: 'key',
        secretAccessKey: 'secret',
        objectStore: store,
      );
      final bytes = Uint8List.fromList([7, 8, 9]);
      await provider.upload(bucket: 'b', path: 'obj', bytes: bytes, mimeType: 'image/jpeg');
      final download = await provider.download(bucket: 'b', path: 'obj');
      expect((download as Success<Uint8List>).data, bytes);
    });
  });
}
