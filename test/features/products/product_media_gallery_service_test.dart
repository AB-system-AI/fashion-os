import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/media_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';
import 'package:fashion_pos_enterprise/features/products/domain/enums/product_enums.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/product_catalog_service.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/product_media_gallery_service.dart';

class _MockCatalog extends Mock implements ProductCatalogService {}

class _MockMedia extends Mock implements MediaEngine {}

class _MockAudit extends Mock implements AuditService {}

void main() {
  late _MockCatalog catalog;
  late _MockMedia media;
  late _MockAudit audit;
  late ProductMediaGalleryService service;
  late AuthUser user;
  late Product product;

  setUpAll(() {
    registerFallbackValue(
      Product(
        id: 'p1',
        tenantId: 't1',
        name: 'Shirt',
        sku: 'SKU-1',
        retailPrice: 10,
        cost: 5,
        status: ProductStatus.active,
        version: 1,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
  });

  setUp(() {
    catalog = _MockCatalog();
    media = _MockMedia();
    audit = _MockAudit();
    service = ProductMediaGalleryService(
      catalogService: catalog,
      mediaEngine: media,
      auditService: audit,
    );
    user = const AuthUser(
      userId: 'u1',
      employeeId: 'e1',
      email: 'a@b.com',
      emailVerified: true,
      tenantId: 't1',
      permissions: {'product.update'},
    );
    product = Product(
      id: 'p1',
      tenantId: 't1',
      name: 'Shirt',
      sku: 'SKU-1',
      retailPrice: 10,
      cost: 5,
      status: ProductStatus.active,
      imageAssetIds: const ['asset-1'],
      version: 1,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    when(() => media.getAsset(any())).thenAnswer(
      (_) async => MediaAsset(
        id: 'asset-1',
        tenantId: 't1',
        category: MediaCategory.product,
        ownerEntityType: 'product',
        ownerEntityId: 'p1',
        mimeType: 'image/webp',
        sizeBytes: 100,
        checksum: 'abc',
        storageBackend: StorageBackend.local,
        syncStatus: MediaSyncStatus.localOnly,
        createdAt: DateTime.now().toUtc(),
      ),
    );
    when(() => media.getBytes(any())).thenAnswer((_) async => Success(Uint8List.fromList([1, 2, 3])));
    when(() => media.getSignedUrl(any())).thenAnswer((_) async => const Error(ValidationFailure(message: 'offline', code: 'offline')));
    when(() => media.processOfflineUploadQueue()).thenAnswer((_) async {});
    when(() => audit.log(
          action: any(named: 'action'),
          entityType: any(named: 'entityType'),
          tenantId: any(named: 'tenantId'),
          employeeId: any(named: 'employeeId'),
          entityId: any(named: 'entityId'),
          metadata: any(named: 'metadata'),
        )).thenAnswer((_) async {});
  });

  test('loadGallery resolves thumbnails offline via MediaEngine', () async {
    final images = await service.loadGallery(product: product);
    expect(images, hasLength(1));
    expect(images.first.assetId, 'asset-1');
    expect(images.first.thumbnailBytes, isNotNull);
    expect(images.first.isPrimary, isTrue);
  });

  test('uploadImage delegates to catalog and audits', () async {
    final asset = MediaAsset(
      id: 'new-asset',
      tenantId: 't1',
      category: MediaCategory.product,
      ownerEntityType: 'product',
      ownerEntityId: 'p1',
      mimeType: 'image/webp',
      sizeBytes: 50,
      checksum: 'x',
      storageBackend: StorageBackend.local,
      syncStatus: MediaSyncStatus.pendingUpload,
      createdAt: DateTime.now().toUtc(),
    );
    when(() => catalog.uploadProductImage(
          user: any(named: 'user'),
          productId: any(named: 'productId'),
          bytes: any(named: 'bytes'),
          filename: any(named: 'filename'),
          tenantId: any(named: 'tenantId'),
        )).thenAnswer((_) async => Success(asset));
    when(() => catalog.attachUploadedImage(
          user: any(named: 'user'),
          product: any(named: 'product'),
          assetId: any(named: 'assetId'),
          primary: any(named: 'primary'),
        )).thenAnswer((_) async => Success(product.copyWith(imageAssetIds: ['new-asset'])));

    final result = await service.uploadImage(
      user: user,
      product: product,
      bytes: Uint8List.fromList([9, 9]),
      filename: 'photo.jpg',
    );

    expect(result.isSuccess, isTrue);
    verify(() => audit.log(
          action: any(named: 'action'),
          entityType: Product.entityTypeName,
          tenantId: 't1',
          employeeId: 'e1',
          entityId: 'p1',
          metadata: any(named: 'metadata'),
        )).called(1);
  });

  test('reorderImages audits image_reorder', () async {
    when(() => catalog.reorderImages(
          user: any(named: 'user'),
          product: any(named: 'product'),
          imageAssetIds: any(named: 'imageAssetIds'),
        )).thenAnswer((_) async => Success(product));

    final result = await service.reorderImages(
      user: user,
      product: product,
      imageAssetIds: const ['asset-1'],
    );

    expect(result.isSuccess, isTrue);
    verify(() => audit.log(
          action: any(named: 'action'),
          entityType: Product.entityTypeName,
          tenantId: 't1',
          employeeId: 'e1',
          entityId: 'p1',
          metadata: any(named: 'metadata'),
        )).called(1);
  });
}
