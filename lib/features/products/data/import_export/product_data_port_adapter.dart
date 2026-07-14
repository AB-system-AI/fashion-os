import 'package:fashion_pos_enterprise/core/import_export/import_export_service.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';
import 'package:fashion_pos_enterprise/features/products/domain/repositories/product_repositories.dart';
import 'package:uuid/uuid.dart';

/// CSV/Excel import adapter for products.
class ProductDataPortAdapter implements DataPortAdapter {
  ProductDataPortAdapter(this._repository, {required this.tenantId, Uuid? uuid})
      : _uuid = uuid ?? const Uuid();

  final ProductRepository _repository;
  final String tenantId;
  final Uuid _uuid;

  @override
  String get entityType => Product.entityTypeName;

  @override
  Future<ImportResult> importRows(List<Map<String, dynamic>> rows) async {
    var imported = 0;
    final errors = <String>[];
    for (var i = 0; i < rows.length; i++) {
      try {
        final row = rows[i];
        final now = DateTime.now().toUtc();
        final product = Product(
          id: row['id']?.toString().isNotEmpty == true ? row['id'].toString() : _uuid.v4(),
          tenantId: tenantId,
          name: row['name']?.toString() ?? 'Unnamed',
          sku: row['sku']?.toString() ?? 'SKU-$i',
          barcode: row['barcode']?.toString(),
          retailPrice: double.tryParse(row['retail_price']?.toString() ?? '') ?? 0,
          cost: double.tryParse(row['cost']?.toString() ?? '') ?? 0,
          categoryName: row['category']?.toString(),
          brandName: row['brand']?.toString(),
          version: 1,
          createdAt: now,
          updatedAt: now,
          syncStatus: LocalSyncStatus.pending,
          isDirty: true,
        );
        if (row['id']?.toString().isNotEmpty == true) {
          final existing = await _repository.getById(product.id);
          if (existing == null) {
            await _repository.create(product);
          } else {
            await _repository.update(product.copyWith(version: existing.version));
          }
        } else {
          await _repository.create(product);
        }
        imported++;
      } catch (e) {
        errors.add('Row ${i + 1}: $e');
      }
    }
    return ImportResult(
      totalRows: rows.length,
      importedRows: imported,
      failedRows: rows.length - imported,
      errors: errors,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> exportRows({Map<String, String> filters = const {}}) async {
    final tenant = filters['tenant_id'] ?? tenantId;
    final page = await _repository.getPage(
      RepositoryQuery(tenantId: tenant, page: 1, pageSize: 10000),
    );
    return page.items
        .map(
          (p) => {
            'id': p.id,
            'name': p.name,
            'sku': p.sku,
            'barcode': p.barcode,
            'retail_price': p.retailPrice,
            'cost': p.cost,
            'category': p.categoryName,
            'brand': p.brandName,
            'status': p.status.value,
          },
        )
        .toList();
  }
}
