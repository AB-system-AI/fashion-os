import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/engines/barcode_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/pricing_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/validation_engine.dart';
import 'package:fashion_pos_enterprise/core/import_export/import_export_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/adapters/remote_storage_adapters.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/barcode/media_barcode_generator.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/cache/media_cache_manager.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/document/document_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/download/download_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/indexing/media_index_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/media_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/optimization/media_optimizer.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/processing/image_processor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/security/media_security_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/storage/local_media_storage.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/upload/upload_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/network/network_monitor.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/network/network_state.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/cache/memory_cache.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/search/product_search_service.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/products/data/import_export/product_data_port_adapter.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';
import 'package:fashion_pos_enterprise/features/products/domain/enums/product_enums.dart';
import 'package:fashion_pos_enterprise/features/products/domain/repositories/product_repositories.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/product_catalog_service.dart';

class _MockProductRepository extends Mock implements ProductRepository {}

class _MockAuditService extends Mock implements AuditService {}

class _OnlineNetworkMonitor extends NetworkMonitor {
  @override
  Future<NetworkState> get currentState async => const NetworkState(
        isOnline: true,
        connectionType: NetworkConnectionType.wifi,
        quality: NetworkQuality.good,
      );
}

Future<MediaEngine> _testMediaEngine(AppDatabase db) async {
  final dir = await Directory.systemTemp.createTemp('catalog_media_test');
  final security = MediaSecurityService(encryptionKey: 'test-key-32-characters-long!!!!!');
  final local = LocalMediaStorage(rootDirectory: dir, security: security);
  final index = MediaIndexRepository(db);
  final store = <String, Uint8List>{};
  return MediaEngine(
    index: index,
    localStorage: local,
    security: security,
    imageProcessor: ImageProcessor(),
    optimizer: MediaOptimizer(imageProcessor: ImageProcessor()),
    uploadEngine: UploadEngine(
      providers: {StorageBackend.local: LocalRemoteStorageProvider(store)},
      localStorage: local,
      index: index,
      networkMonitor: _OnlineNetworkMonitor(),
    ),
    downloadEngine: DownloadEngine(
      providers: {StorageBackend.local: LocalRemoteStorageProvider(store)},
      localStorage: local,
      index: index,
    ),
    cacheManager: MediaCacheManager(
      memoryCache: MemoryCache<String, Uint8List>(maxEntries: 32),
      localStorage: local,
      security: security,
    ),
    documentEngine: DocumentEngine(),
    barcodeGenerator: MediaBarcodeGenerator(),
    networkMonitor: _OnlineNetworkMonitor(),
    storageProviders: {StorageBackend.local: LocalRemoteStorageProvider(store)},
  );
}

void main() {
  late _MockProductRepository repository;
  late _MockAuditService audit;
  late ProductCatalogService service;
  late AuthUser user;

  setUpAll(() {
    registerFallbackValue(
      Product(
        id: 'fallback',
        tenantId: 'tenant-1',
        name: 'x',
        sku: 'x',
        version: 1,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
  });

  setUp(() async {
    repository = _MockProductRepository();
    audit = _MockAuditService();
    final db = AppDatabase.inMemory();
    await db.executor.ensureOpen(db);
    service = ProductCatalogService(
      repository: repository,
      validationEngine: ValidationEngine(),
      barcodeEngine: BarcodeEngine(),
      numberGenerator: NumberGeneratorEngine(),
      pricingEngine: PricingEngine(),
      mediaEngine: await _testMediaEngine(db),
      auditService: audit,
      permissionEngine: const PermissionEngine(),
      searchService: ProductSearchService(),
      importExportService: ImportExportService(),
      importAdapter: ProductDataPortAdapter(repository, tenantId: 'tenant-1'),
    );

    user = const AuthUser(
      userId: 'u1',
      employeeId: 'e1',
      email: 'owner@store.com',
      emailVerified: true,
      tenantId: 'tenant-1',
      permissions: {'product.create', 'product.update', 'product.read'},
    );

    when(() => repository.create(any())).thenAnswer((invocation) async {
      return invocation.positionalArguments.first as Product;
    });
    when(
      () => audit.log(
        action: any(named: 'action'),
        entityType: any(named: 'entityType'),
        tenantId: any(named: 'tenantId'),
        employeeId: any(named: 'employeeId'),
        entityId: any(named: 'entityId'),
        newValue: any(named: 'newValue'),
        oldValue: any(named: 'oldValue'),
        metadata: any(named: 'metadata'),
      ),
    ).thenAnswer((_) async {});
  });

  Product draft() {
    final now = DateTime.now().toUtc();
    return Product(
      id: '',
      tenantId: 'tenant-1',
      name: 'Linen Dress',
      sku: 'DRS-001',
      retailPrice: 120,
      cost: 45,
      status: ProductStatus.draft,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
  }

  test('createProduct assigns id and persists via repository', () async {
    final result = await service.createProduct(user: user, draft: draft());
    expect(result.isSuccess, isTrue);
    final product = result.dataOrNull!;
    expect(product.id, isNotEmpty);
    expect(product.status, ProductStatus.active);
    verify(() => repository.create(any())).called(1);
    verify(
      () => audit.log(
        action: AuditAction.create,
        entityType: Product.entityTypeName,
        tenantId: any(named: 'tenantId'),
        employeeId: user.employeeId,
        entityId: any(named: 'entityId'),
        newValue: any(named: 'newValue'),
      ),
    ).called(1);
  });

  test('createProduct denies without permission', () async {
    final deniedUser = user.copyWith(permissions: {});
    final result = await service.createProduct(user: deniedUser, draft: draft());
    expect(result.isFailure, isTrue);
    verifyNever(() => repository.create(any()));
  });
}
