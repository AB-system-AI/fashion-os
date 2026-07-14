import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/domain/entities/pricing_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/entities/rule_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/business/engines/barcode_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/pricing_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/validation_engine.dart';
import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/import_export/import_export_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/enums/media_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/domain/media_models.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/media/media_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/search/product_search_service.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/products/data/import_export/product_data_port_adapter.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';
import 'package:fashion_pos_enterprise/features/products/domain/enums/product_enums.dart';
import 'package:fashion_pos_enterprise/features/products/domain/repositories/product_repositories.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product_variant.dart';
import 'package:fashion_pos_enterprise/features/products/domain/models/product_list_filters.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/product_inventory_preview_service.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/variant_matrix_generator.dart';

/// Product catalog domain service — all business rules live here, not in UI.
class ProductCatalogService {
  ProductCatalogService({
    required ProductRepository repository,
    required ValidationEngine validationEngine,
    required BarcodeEngine barcodeEngine,
    required NumberGeneratorEngine numberGenerator,
    required PricingEngine pricingEngine,
    required MediaEngine mediaEngine,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    required ProductSearchService searchService,
    required ImportExportService importExportService,
    required     ProductDataPortAdapter importAdapter,
    ProductInventoryPreviewService? inventoryPreview,
    VariantMatrixGenerator? variantMatrix,
    DomainEventBus? eventBus,
    Uuid? uuid,
  })  : _repository = repository,
        _validation = validationEngine,
        _barcode = barcodeEngine,
        _numbers = numberGenerator,
        _pricing = pricingEngine,
        _media = mediaEngine,
        _audit = auditService,
        _permissions = permissionEngine,
        _search = searchService,
        _importExport = importExportService,
        _importAdapter = importAdapter,
        _inventoryPreview = inventoryPreview ?? ProductInventoryPreviewService(),
        _variantMatrix = variantMatrix ?? const VariantMatrixGenerator(),
        _eventBus = eventBus,
        _uuid = uuid ?? const Uuid();

  final ProductRepository _repository;
  final ValidationEngine _validation;
  final BarcodeEngine _barcode;
  final NumberGeneratorEngine _numbers;
  final PricingEngine _pricing;
  final MediaEngine _media;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final ProductSearchService _search;
  final ImportExportService _importExport;
  final ProductDataPortAdapter _importAdapter;
  final ProductInventoryPreviewService _inventoryPreview;
  final VariantMatrixGenerator _variantMatrix;
  final DomainEventBus? _eventBus;
  final Uuid _uuid;

  Future<Result<Product>> getById(String id, {AuthUser? user}) async {
    if (user != null) {
      try {
        _permissions.require(user, ProductPermissions.read);
      } on PermissionDeniedException catch (e) {
        return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
      }
    }
    final product = await _repository.getById(id, tenantId: user?.tenantId);
    if (product == null) {
      return const Error(ValidationFailure(message: 'Product not found', code: 'not_found'));
    }
    return Success(product);
  }

  Future<PaginatedResult<Product>> list({
    required AuthUser user,
    required String tenantId,
    int page = 1,
    int pageSize = 50,
    ProductSortField sort = ProductSortField.updatedAt,
    bool descending = true,
    Map<String, String> filters = const {},
    ProductListFilters? advancedFilters,
    bool includeDeleted = false,
  }) async {
    try {
      _permissions.require(user, ProductPermissions.read);
    } on PermissionDeniedException catch (e) {
      return PaginatedResult(
        items: const [],
        page: page,
        pageSize: pageSize,
        totalCount: 0,
        hasMore: false,
      );
    }
    final pageResult = await _repository.getPage(
      RepositoryQuery(
        tenantId: tenantId,
        page: page,
        pageSize: pageSize,
        sortBy: sort.value,
        sortDescending: descending,
        filters: advancedFilters?.toRepositoryFilters() ?? filters,
        includeDeleted: includeDeleted,
      ),
    );
    if (advancedFilters == null) return pageResult;

    final filtered = pageResult.items.where((p) {
      return advancedFilters.matchesProduct(
        retailPrice: p.retailPrice,
        cost: p.cost,
        createdAt: p.createdAt,
        updatedAt: p.updatedAt,
        hasImages: p.imageAssetIds.isNotEmpty,
        hasVariantRows: p.variants.isNotEmpty,
        productTags: p.tags,
      );
    }).toList();

    return PaginatedResult(
      items: filtered,
      page: pageResult.page,
      pageSize: pageResult.pageSize,
      totalCount: filtered.length,
      hasMore: pageResult.hasMore,
    );
  }

  Future<Result<List<ProductSearchResult>>> search({
    required AuthUser user,
    required String tenantId,
    required String query,
    int limit = 50,
  }) async {
    try {
      _permissions.require(user, ProductPermissions.read);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final results = await _search.search(tenantId: tenantId, query: query, limit: limit);
    return Success(results);
  }

  Future<Result<Product>> createProduct({
    required AuthUser user,
    required Product draft,
    Set<String> existingSkus = const {},
    Set<String> existingBarcodes = const {},
  }) async {
    try {
      _permissions.require(user, ProductPermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final validation = _validation.validateAll([
      _validation.validatePrice(draft.retailPrice),
      _validation.validateDuplicateSku(sku: draft.sku, existingSkus: existingSkus),
      if (draft.barcode != null)
        _validation.validateDuplicateBarcode(barcode: draft.barcode!, existingBarcodes: existingBarcodes),
      if (draft.barcode != null && draft.barcode!.length == 13)
        _validateEan13(draft.barcode!),
    ]);
    if (validation.isFailure) return Error(validation.failureOrNull!);

    final now = DateTime.now().toUtc();
    final product = draft.copyWith(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      tenantId: user.tenantId ?? draft.tenantId,
      status: ProductStatus.active,
      version: 1,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    final created = await _repository.create(product);
    await _audit.log(
      action: AuditAction.create,
      entityType: Product.entityTypeName,
      tenantId: created.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
      newValue: created.toPayload(),
    );
    _eventBus?.publish(
      ProductUpdatedEvent(
        eventId: created.id,
        occurredAt: now,
        productId: created.id,
        tenantId: created.tenantId,
      ),
    );
    return Success(created);
  }

  Future<Result<Product>> updateProduct({
    required AuthUser user,
    required Product product,
    Product? previous,
    Set<String> existingSkus = const {},
    Set<String> existingBarcodes = const {},
  }) async {
    try {
      _permissions.require(user, ProductPermissions.update);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final validation = _validation.validateAll([
      _validation.validatePrice(product.retailPrice),
      _validation.validateDuplicateSku(sku: product.sku, existingSkus: existingSkus.difference({previous?.sku})),
      if (product.barcode != null)
        _validation.validateDuplicateBarcode(
          barcode: product.barcode!,
          existingBarcodes: existingBarcodes.difference({previous?.barcode}.whereType<String>()),
        ),
      if (product.barcode != null && product.barcode!.length == 13)
        _validateEan13(product.barcode!),
    ]);
    if (validation.isFailure) return Error(validation.failureOrNull!);

    final updated = await _repository.update(product);
    await _audit.log(
      action: AuditAction.update,
      entityType: Product.entityTypeName,
      tenantId: updated.tenantId,
      employeeId: user.employeeId,
      entityId: updated.id,
      oldValue: previous?.toPayload(),
      newValue: updated.toPayload(),
    );
    if (previous != null && previous.retailPrice != updated.retailPrice) {
      await _audit.log(
        action: AuditAction.priceChange,
        entityType: Product.entityTypeName,
        tenantId: updated.tenantId,
        employeeId: user.employeeId,
        entityId: updated.id,
        oldValue: previous.retailPrice,
        newValue: updated.retailPrice,
      );
    }
    if (previous != null && previous.barcode != updated.barcode) {
      await _audit.log(
        action: AuditAction.update,
        entityType: Product.entityTypeName,
        tenantId: updated.tenantId,
        employeeId: user.employeeId,
        entityId: updated.id,
        metadata: {'change_type': 'barcode'},
        oldValue: previous.barcode,
        newValue: updated.barcode,
      );
    }
    _eventBus?.publish(
      ProductUpdatedEvent(
        eventId: updated.id,
        occurredAt: DateTime.now().toUtc(),
        productId: updated.id,
        tenantId: updated.tenantId,
      ),
    );
    return Success(updated);
  }

  Future<Result<void>> deleteProduct({required AuthUser user, required String productId}) async {
    try {
      _permissions.require(user, ProductPermissions.delete);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    await _repository.softDelete(productId);
    await _audit.log(
      action: AuditAction.delete,
      entityType: Product.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: productId,
    );
    return const Success(null);
  }

  Future<Result<Product>> restoreProduct({required AuthUser user, required String productId}) async {
    try {
      _permissions.require(user, ProductPermissions.update);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    await _repository.restore(productId);
    final restored = await _repository.getById(productId, tenantId: user.tenantId);
    if (restored == null) {
      return const Error(ValidationFailure(message: 'Product not found', code: 'not_found'));
    }
    await _audit.log(
      action: AuditAction.update,
      entityType: Product.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: productId,
      metadata: {'action': 'restore'},
    );
    return Success(restored);
  }

  Future<Result<Product>> archiveProduct({required AuthUser user, required Product product}) async {
    return updateProduct(
      user: user,
      product: product.copyWith(status: ProductStatus.archived),
      previous: product,
    );
  }

  Future<Result<Product>> duplicateProduct({required AuthUser user, required Product source}) async {
    final skuResult = await _numbers.next(type: DocumentNumberType.sku, tenantId: source.tenantId);
    final newSku = skuResult.isSuccess ? (skuResult as Success<GeneratedNumber>).data.value : '${source.sku}-copy';

    return createProduct(
      user: user,
      draft: source.copyWith(
        id: '',
        name: '${source.name} (Copy)',
        sku: newSku,
        barcode: null,
        status: ProductStatus.draft,
        imageAssetIds: const [],
        variants: source.variants
            .map((v) => v.copyWith(barcode: null, imageAssetIds: const []))
            .toList(),
      ),
    );
  }

  Future<Result<Product>> toggleFavorite({required AuthUser user, required Product product}) async {
    return updateProduct(
      user: user,
      product: product.copyWith(isFavorite: !product.isFavorite),
      previous: product,
    );
  }

  Future<Result<List<Product>>> bulkArchive({
    required AuthUser user,
    required List<String> productIds,
  }) async {
    try {
      _permissions.require(user, ProductPermissions.bulk);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final updated = <Product>[];
    for (final id in productIds) {
      final current = await _repository.getById(id, tenantId: user.tenantId);
      if (current == null) continue;
      final result = await archiveProduct(user: user, product: current);
      if (result.isSuccess) updated.add((result as Success<Product>).data);
    }
    return Success(updated);
  }

  Future<Result<MediaAsset>> uploadProductImage({
    required AuthUser user,
    required String productId,
    required Uint8List bytes,
    required String filename,
    required String tenantId,
  }) async {
    try {
      _permissions.require(user, ProductPermissions.update);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final result = await _media.upload(
      MediaUploadRequest(
        tenantId: tenantId,
        category: MediaCategory.product,
        ownerEntityType: 'product',
        ownerEntityId: productId,
        bytes: bytes,
        filename: filename,
        generateThumbnail: true,
        uploadImmediately: true,
      ),
    );
    if (result.isSuccess) {
      await _audit.log(
        action: AuditAction.update,
        entityType: Product.entityTypeName,
        tenantId: tenantId,
        employeeId: user.employeeId,
        entityId: productId,
        metadata: {'change_type': 'media'},
        newValue: (result as Success<MediaAsset>).data.id,
      );
    }
    return result;
  }

  Future<Result<Money>> resolveDisplayPrice(Product product, {PriceListType listType = PriceListType.retail}) {
    return _pricing.resolvePrice(
      PricingContext(
        productId: product.id,
        baseRetailPrice: Money.fromMajor(product.retailPrice),
        costPrice: Money.fromMajor(product.cost),
        categoryId: product.categoryId,
        brandId: product.brandId,
        priceListType: listType,
      ),
    ).then((r) => r.map((p) => p.unitPrice));
  }

  Future<Result<String>> generateBarcode(String value) async {
    final result = _barcode.generate(format: BarcodeFormat.ean13, value: value);
    return result.map((p) => p.value);
  }

  Future<Result<ImportResult>> importCsv({
    required AuthUser user,
    required String csvContent,
  }) async {
    try {
      _permissions.require(user, ProductPermissions.import);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final rows = await _importExport.parseCsv(csvContent);
    final result = await _importExport.importViaAdapter(adapter: _importAdapter, rows: rows);
    await _audit.log(
      action: AuditAction.importData,
      entityType: Product.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      metadata: {'imported': result.importedRows, 'failed': result.failedRows},
    );
    return Success(result);
  }

  Future<Result<ExportPayload>> exportCsv({
    required AuthUser user,
    required String tenantId,
  }) async {
    try {
      _permissions.require(user, ProductPermissions.export);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final rows = await _importAdapter.exportRows(filters: {'tenant_id': tenantId});
    final payload = await _importExport.exportCsv(entityType: Product.entityTypeName, rows: rows);
    await _audit.log(
      action: AuditAction.export,
      entityType: Product.entityTypeName,
      tenantId: tenantId,
      employeeId: user.employeeId,
    );
    return Success(payload);
  }

  Future<List<AuditEntry>> productTimeline(String productId, {int limit = 100}) {
    return _audit.getEntityTimeline(
      entityType: Product.entityTypeName,
      entityId: productId,
      limit: limit,
    );
  }

  InventoryPreviewSummary inventoryPreview(Product product) => _inventoryPreview.summarize(product);

  List<ProductVariant> generateVariantMatrix(VariantMatrixInput input) => _variantMatrix.generate(input);

  Future<Result<Product>> updateVariants({
    required AuthUser user,
    required Product product,
    required List<ProductVariant> variants,
  }) async {
    try {
      _permissions.require(user, ProductPermissions.variantManage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final previous = product;
    final normalized = <ProductVariant>[];
    for (final v in variants) {
      normalized.add(
        v.id.startsWith('draft-')
            ? ProductVariant(
                id: _uuid.v4(),
                sku: v.sku,
                barcode: v.barcode,
                color: v.color,
                size: v.size,
                style: v.style,
                material: v.material,
                pattern: v.pattern,
                customAttributes: v.customAttributes,
                retailPriceOverride: v.retailPriceOverride,
                costOverride: v.costOverride,
                wholesalePriceOverride: v.wholesalePriceOverride,
                stockQuantity: v.stockQuantity,
                weightGrams: v.weightGrams,
                imageAssetIds: v.imageAssetIds,
                isActive: v.isActive,
                status: v.status,
              )
            : v,
      );
    }

    final result = await updateProduct(
      user: user,
      product: product.copyWith(variants: normalized),
      previous: previous,
    );
    if (result.isSuccess) {
      await _audit.log(
        action: AuditAction.update,
        entityType: Product.entityTypeName,
        tenantId: product.tenantId,
        employeeId: user.employeeId,
        entityId: product.id,
        metadata: {'change_type': 'variants', 'count': normalized.length},
      );
    }
    return result;
  }

  Future<Result<Product>> reorderImages({
    required AuthUser user,
    required Product product,
    required List<String> imageAssetIds,
  }) async {
    return updateProduct(
      user: user,
      product: product.copyWith(imageAssetIds: imageAssetIds),
      previous: product,
    );
  }

  Future<Result<Product>> removeImage({
    required AuthUser user,
    required Product product,
    required String assetId,
  }) async {
    final next = product.imageAssetIds.where((id) => id != assetId).toList();
    return updateProduct(user: user, product: product.copyWith(imageAssetIds: next), previous: product);
  }

  Future<Result<Product>> attachUploadedImage({
    required AuthUser user,
    required Product product,
    required String assetId,
    bool primary = false,
  }) async {
    final ids = List<String>.from(product.imageAssetIds);
    if (!ids.contains(assetId)) {
      primary ? ids.insert(0, assetId) : ids.add(assetId);
    }
    return updateProduct(user: user, product: product.copyWith(imageAssetIds: ids), previous: product);
  }

  Future<Result<String>> generateProductBarcode({String? seed}) async {
    final value = seed ?? DateTime.now().millisecondsSinceEpoch.toString().padLeft(12, '0').substring(0, 12);
    return generateBarcode(value);
  }

  Future<Result<String>> regenerateBarcode({
    required AuthUser user,
    required Product product,
  }) async {
    final generated = await generateProductBarcode(seed: product.sku);
    if (generated.isFailure) return generated;
    final updated = await updateProduct(
      user: user,
      product: product.copyWith(barcode: generated.dataOrNull),
      previous: product,
    );
    return updated.map((p) => p.barcode ?? '');
  }

  Future<Result<List<Product>>> bulkDelete({
    required AuthUser user,
    required List<String> productIds,
  }) async {
    try {
      _permissions.require(user, ProductPermissions.bulk);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    for (final id in productIds) {
      await deleteProduct(user: user, productId: id);
    }
    await _audit.log(
      action: AuditAction.delete,
      entityType: Product.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      metadata: {'bulk': true, 'count': productIds.length},
    );
    return Success(await _loadProducts(productIds));
  }

  Future<Result<List<Product>>> bulkRestore({
    required AuthUser user,
    required List<String> productIds,
  }) async {
    try {
      _permissions.require(user, ProductPermissions.bulk);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final restored = <Product>[];
    for (final id in productIds) {
      final result = await restoreProduct(user: user, productId: id);
      if (result.isSuccess) restored.add(result.dataOrNull!);
    }
    await _audit.log(
      action: AuditAction.update,
      entityType: Product.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      metadata: {'bulk': 'restore', 'count': restored.length},
    );
    return Success(restored);
  }

  Future<Result<List<Product>>> bulkActivate({
    required AuthUser user,
    required List<String> productIds,
  }) => _bulkStatus(user: user, productIds: productIds, status: ProductStatus.active, label: 'activate');

  Future<Result<List<Product>>> bulkDeactivate({
    required AuthUser user,
    required List<String> productIds,
  }) => _bulkStatus(user: user, productIds: productIds, status: ProductStatus.inactive, label: 'deactivate');

  Future<Result<List<Product>>> bulkUpdate({
    required AuthUser user,
    required List<String> productIds,
    required BulkProductUpdate update,
  }) async {
    try {
      _permissions.require(user, ProductPermissions.bulk);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final updated = <Product>[];
    for (final id in productIds) {
      final current = await _repository.getById(id, tenantId: user.tenantId);
      if (current == null) continue;
      final next = current.copyWith(
        retailPrice: update.retailPrice ?? current.retailPrice,
        taxGroupId: update.taxGroupId ?? current.taxGroupId,
        categoryId: update.categoryId ?? current.categoryId,
        categoryName: update.categoryName ?? current.categoryName,
        brandId: update.brandId ?? current.brandId,
        brandName: update.brandName ?? current.brandName,
        supplierId: update.supplierId ?? current.supplierId,
        status: update.status ?? current.status,
      );
      final result = await updateProduct(user: user, product: next, previous: current);
      if (result.isSuccess) updated.add(result.dataOrNull!);
    }
    await _audit.log(
      action: AuditAction.update,
      entityType: Product.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      metadata: {'bulk': 'update', 'count': updated.length},
    );
    return Success(updated);
  }

  Future<Result<ImportValidationReport>> previewImport({
    required AuthUser user,
    required String content,
    ImportFormat format = ImportFormat.csv,
  }) async {
    try {
      _permissions.require(user, ProductPermissions.import);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final rows = format == ImportFormat.excel
        ? await _importExport.parseExcel(content)
        : await _importExport.parseCsv(content);
    final report = await _importExport.validateRows(
      rows: rows,
      validateRow: (row, index) async {
        final name = row['name']?.toString();
        final sku = row['sku']?.toString();
        if (name == null || name.isEmpty) return 'Row ${index + 1}: name is required';
        if (sku == null || sku.isEmpty) return 'Row ${index + 1}: sku is required';
        final existing = await _repository.findBySku(user.tenantId ?? '', sku);
        if (existing != null && row['id']?.toString() != existing.id) {
          return 'Duplicate SKU in catalog: $sku';
        }
        return null;
      },
    );
    return Success(report);
  }

  Future<Result<ImportResult>> importWithRollback({
    required AuthUser user,
    required String content,
    ImportFormat format = ImportFormat.csv,
  }) async {
    try {
      _permissions.require(user, ProductPermissions.import);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final preview = await previewImport(user: user, content: content, format: format);
    if (preview.isFailure) return Error(preview.failureOrNull!);
    if (!preview.dataOrNull!.canImport) {
      return Error(ValidationFailure(
        message: 'Import validation failed: ${preview.dataOrNull!.issues.length} issues',
        code: 'validation_failed',
      ));
    }

    final rows = format == ImportFormat.excel
        ? await _importExport.parseExcel(content)
        : await _importExport.parseCsv(content);
    final createdIds = <String>[];
    try {
      final result = await _importExport.importViaAdapter(adapter: _importAdapter, rows: rows);
      for (final row in rows) {
        final id = row['id']?.toString();
        if (id != null && id.isNotEmpty) createdIds.add(id);
      }
      await _audit.log(
        action: AuditAction.importData,
        entityType: Product.entityTypeName,
        tenantId: user.tenantId,
        employeeId: user.employeeId,
        metadata: {'imported': result.importedRows, 'failed': result.failedRows},
      );
      return Success(result);
    } catch (e) {
      for (final id in createdIds) {
        await _repository.softDelete(id);
      }
      return Error(ValidationFailure(message: 'Import rolled back: $e', code: 'import_rollback'));
    }
  }

  Future<Result<ExportPayload>> exportExcel({
    required AuthUser user,
    required String tenantId,
    List<String>? productIds,
    ProductListFilters? filters,
  }) => _export(user: user, tenantId: tenantId, productIds: productIds, filters: filters, format: ExportFormat.excel);

  Future<Result<ExportPayload>> exportPdfCatalog({
    required AuthUser user,
    required String tenantId,
    List<String>? productIds,
    ProductListFilters? filters,
  }) async {
    try {
      _permissions.require(user, ProductPermissions.export);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final rows = await _exportRows(tenantId: tenantId, productIds: productIds, filters: filters);
    final payload = await _importExport.exportPdfCatalog(title: 'FashionOS Product Catalog', rows: rows);
    await _audit.log(
      action: AuditAction.export,
      entityType: Product.entityTypeName,
      tenantId: tenantId,
      employeeId: user.employeeId,
      metadata: {'format': 'pdf', 'rows': rows.length},
    );
    return Success(payload);
  }

  Future<Result<ExportPayload>> _export({
    required AuthUser user,
    required String tenantId,
    List<String>? productIds,
    ProductListFilters? filters,
    required ExportFormat format,
  }) async {
    try {
      _permissions.require(user, ProductPermissions.export);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final rows = await _exportRows(tenantId: tenantId, productIds: productIds, filters: filters);
    final payload = format == ExportFormat.excel
        ? await _importExport.exportExcel(entityType: Product.entityTypeName, rows: rows)
        : await _importExport.exportCsv(entityType: Product.entityTypeName, rows: rows);
    await _audit.log(
      action: AuditAction.export,
      entityType: Product.entityTypeName,
      tenantId: tenantId,
      employeeId: user.employeeId,
      metadata: {'format': format.name, 'rows': rows.length},
    );
    return Success(payload);
  }

  Future<List<Map<String, dynamic>>> _exportRows({
    required String tenantId,
    List<String>? productIds,
    ProductListFilters? filters,
  }) async {
    if (productIds != null && productIds.isNotEmpty) {
      final rows = <Map<String, dynamic>>[];
      for (final id in productIds) {
        final product = await _repository.getById(id, tenantId: tenantId);
        if (product != null) rows.add(_productExportRow(product));
      }
      return rows;
    }
    return _importAdapter.exportRows(filters: {
      'tenant_id': tenantId,
      ...?filters?.toRepositoryFilters(),
    });
  }

  Map<String, dynamic> _productExportRow(Product product) => {
        'id': product.id,
        'name': product.name,
        'sku': product.sku,
        'barcode': product.barcode,
        'retail_price': product.retailPrice,
        'cost': product.cost,
        'category': product.categoryName,
        'brand': product.brandName,
        'status': product.status.value,
      };

  Future<Result<List<Product>>> _bulkStatus({
    required AuthUser user,
    required List<String> productIds,
    required ProductStatus status,
    required String label,
  }) async {
    try {
      _permissions.require(user, ProductPermissions.bulk);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    final updated = <Product>[];
    for (final id in productIds) {
      final current = await _repository.getById(id, tenantId: user.tenantId);
      if (current == null) continue;
      final result = await updateProduct(user: user, product: current.copyWith(status: status), previous: current);
      if (result.isSuccess) updated.add(result.dataOrNull!);
    }
    await _audit.log(
      action: AuditAction.update,
      entityType: Product.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      metadata: {'bulk': label, 'count': updated.length},
    );
    return Success(updated);
  }

  Future<List<Product>> _loadProducts(List<String> ids, {String? tenantId}) async {
    final products = <Product>[];
    for (final id in ids) {
      final p = await _repository.getById(id, tenantId: tenantId);
      if (p != null) products.add(p);
    }
    return products;
  }

  Result<void> _validateEan13(String barcode) {
    final result = _barcode.validateEan13(barcode);
    if (result.isFailure) return Error(result.failureOrNull!);
    if (result.dataOrNull != true) {
      return const Error(ValidationFailure(message: 'Invalid EAN-13 barcode', code: 'invalid_barcode'));
    }
    return const Success(null);
  }
}
