import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/media_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/product_media_gallery_service.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/product_catalog_service.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';
import 'package:fashion_pos_enterprise/features/products/domain/enums/product_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';

class _MockCatalog extends Mock implements ProductCatalogService {}

class _MockMedia extends Mock implements MediaEngine {}

class _MockAudit extends Mock implements AuditService {}

void main() {
  test('loadGallery uses local bytes when signed URL unavailable', () async {
    final media = _MockMedia();
    when(() => media.getAsset('offline-asset')).thenAnswer(
      (_) async => MediaAsset(
        id: 'offline-asset',
        tenantId: 't1',
        category: MediaCategory.product,
        ownerEntityType: 'product',
        ownerEntityId: 'p1',
        mimeType: 'image/webp',
        sizeBytes: 10,
        checksum: 'x',
        syncStatus: MediaSyncStatus.localOnly,
        createdAt: DateTime.now().toUtc(),
      ),
    );
    when(() => media.getSignedUrl('offline-asset')).thenAnswer(
      (_) async => const Error(ValidationFailure(message: 'offline', code: 'offline')),
    );
    when(() => media.getBytes('offline-asset_thumb')).thenAnswer(
      (_) async => Success(Uint8List.fromList([4, 5, 6])),
    );

    final service = ProductMediaGalleryService(
      catalogService: _MockCatalog(),
      mediaEngine: media,
      auditService: _MockAudit(),
    );

    final product = Product(
      id: 'p1',
      tenantId: 't1',
      name: 'Hat',
      sku: 'H1',
      retailPrice: 5,
      cost: 2,
      status: ProductStatus.active,
      imageAssetIds: const ['offline-asset'],
      version: 1,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    final images = await service.loadGallery(product: product);
    expect(images.first.thumbnailBytes, [4, 5, 6]);
    expect(images.first.displayUrl, isNull);
  });
}
