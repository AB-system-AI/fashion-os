import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/core/business/di/business_providers.dart';
import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/core/import_export/import_export_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/hardware/di/hardware_providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/core/search/product_search_service.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/products/data/datasources/brand_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/products/data/datasources/category_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/products/data/datasources/product_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/products/data/import_export/product_data_port_adapter.dart';
import 'package:fashion_pos_enterprise/features/products/data/repositories/brand_category_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/products/data/repositories/product_repository_impl.dart';
import 'package:fashion_pos_enterprise/features/products/data/sync/brand_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/products/data/sync/category_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/products/data/sync/product_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/products/domain/repositories/product_repositories.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/barcode_label_print_service.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/brand_catalog_service.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/category_catalog_service.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/product_catalog_service.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/product_media_gallery_service.dart';

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  return ProductRemoteDataSource();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final brandRepositoryProvider = Provider<BrandRepository>((ref) {
  return BrandRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    syncQueue: ref.watch(syncQueueWriterProvider),
  );
});

final productSearchServiceProvider = Provider<ProductSearchService>((ref) => ProductSearchService());

final importExportServiceProvider = Provider<ImportExportService>((ref) => ImportExportService());

final productDataPortAdapterProvider = Provider<ProductDataPortAdapter>((ref) {
  final tenantId = ref.watch(authControllerProvider.select((s) => s.user?.tenantId ?? ''));
  return ProductDataPortAdapter(
    ref.watch(productRepositoryProvider),
    tenantId: tenantId,
  );
});

final productCatalogServiceProvider = Provider<ProductCatalogService>((ref) {
  return ProductCatalogService(
    repository: ref.watch(productRepositoryProvider),
    validationEngine: ref.watch(validationEngineProvider),
    barcodeEngine: ref.watch(barcodeEngineProvider),
    numberGenerator: ref.watch(numberGeneratorEngineProvider),
    pricingEngine: ref.watch(pricingEngineProvider),
    mediaEngine: ref.watch(mediaEngineProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
    searchService: ref.watch(productSearchServiceProvider),
    importExportService: ref.watch(importExportServiceProvider),
    importAdapter: ref.watch(productDataPortAdapterProvider),
    eventBus: ref.watch(domainEventBusProvider),
  );
});

final categoryCatalogServiceProvider = Provider<CategoryCatalogService>((ref) {
  return CategoryCatalogService(
    repository: ref.watch(categoryRepositoryProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});

final brandCatalogServiceProvider = Provider<BrandCatalogService>((ref) {
  return BrandCatalogService(
    repository: ref.watch(brandRepositoryProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});

final productSyncProcessorProvider = Provider<ProductSyncProcessor>((ref) {
  return ProductSyncProcessor(ref.watch(productRemoteDataSourceProvider));
});

final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((ref) {
  return CategoryRemoteDataSource();
});

final brandRemoteDataSourceProvider = Provider<BrandRemoteDataSource>((ref) {
  return BrandRemoteDataSource();
});

final categorySyncProcessorProvider = Provider<CategorySyncProcessor>((ref) {
  return CategorySyncProcessor(
    ref.watch(categoryRemoteDataSourceProvider),
    auditService: ref.watch(auditServiceProvider),
  );
});

final brandSyncProcessorProvider = Provider<BrandSyncProcessor>((ref) {
  return BrandSyncProcessor(
    ref.watch(brandRemoteDataSourceProvider),
    auditService: ref.watch(auditServiceProvider),
  );
});

final productMediaGalleryServiceProvider = Provider<ProductMediaGalleryService>((ref) {
  return ProductMediaGalleryService(
    catalogService: ref.watch(productCatalogServiceProvider),
    mediaEngine: ref.watch(mediaEngineProvider),
    auditService: ref.watch(auditServiceProvider),
  );
});

final barcodeLabelPrintServiceProvider = Provider<BarcodeLabelPrintService>((ref) {
  return BarcodeLabelPrintService(
    barcodeEngine: ref.watch(barcodeEngineProvider),
    printerHub: ref.watch(printerHubProvider),
    auditService: ref.watch(auditServiceProvider),
    permissionEngine: ref.watch(permissionEngineProvider),
  );
});
