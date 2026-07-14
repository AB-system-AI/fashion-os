import 'package:drift/drift.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/database_initializer.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';

/// Product search result from local FTS index.
class ProductSearchResult {
  const ProductSearchResult({
    required this.productId,
    required this.name,
    this.sku,
    this.barcode,
    this.category,
    this.brand,
    this.color,
    this.size,
    this.retailPrice = 0,
    this.rank = 0,
  });

  final String productId;
  final String name;
  final String? sku;
  final String? barcode;
  final String? category;
  final String? brand;
  final String? color;
  final String? size;
  final double retailPrice;
  final double rank;
}

/// Full-text product search — target <100ms for 100k+ products.
class ProductSearchService {
  static const String _entityType = 'product';

  Future<List<ProductSearchResult>> search({
    required String tenantId,
    required String query,
    int limit = 50,
  }) async {
    final trimmed = query.trim();
    final db = DatabaseInitializer.database;

    if (trimmed.isEmpty) {
      final rows = await db.syncableRecordDao.getPage(
        RepositoryQuery(tenantId: tenantId, entityType: _entityType, pageSize: limit),
      );
      return rows.map(_mapRecord).toList();
    }

    final stopwatch = Stopwatch()..start();
    final ftsQuery = _buildFtsQuery(trimmed);
    final records = await db.syncableRecordDao.searchFts(
      tenantId: tenantId,
      entityType: _entityType,
      ftsQuery: ftsQuery,
      limit: limit,
    );

    stopwatch.stop();
    if (stopwatch.elapsedMilliseconds > 100) {
      AppLogger.warning(
        'Product search exceeded 100ms: ${stopwatch.elapsedMilliseconds}ms query="$trimmed"',
      );
    }

    return records.map(_mapRecord).toList();
  }

  Future<ProductSearchResult?> findByBarcode({
    required String tenantId,
    required String barcode,
  }) async {
    final db = DatabaseInitializer.database;
    final record = await db.syncableRecordDao.getByBarcode(
      tenantId: tenantId,
      barcode: barcode,
      entityType: _entityType,
    );
    return record == null ? null : _mapRecord(record);
  }

  Future<void> indexProduct({
    required String productId,
    required String tenantId,
    required String name,
    String? sku,
    String? barcode,
  }) async {
    final db = DatabaseInitializer.database;
    final now = DateTime.now().toUtc();
    await db.syncableRecordDao.insertRecord(
      SyncableRecordsCompanion.insert(
        id: productId,
        tenantId: tenantId,
        entityType: _entityType,
        payload: '{"id":"$productId","name":"${name.replaceAll('"', '\\"')}"}',
        version: const Value(1),
        createdAt: now,
        updatedAt: now,
        searchName: Value(name),
        searchSku: Value(sku),
        searchBarcode: Value(barcode),
      ),
    );
  }

  Future<void> rebuildIndex(String tenantId) async {
    await DatabaseInitializer.database.syncableRecordDao.rebuildFtsIndex(
      tenantId: tenantId,
      entityType: _entityType,
    );
  }

  String _buildFtsQuery(String input) {
    final tokens = input
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .map((t) => '"${t.replaceAll('"', '""')}"*')
        .join(' ');
    return tokens.isEmpty ? '""' : tokens;
  }

  ProductSearchResult _mapRecord(LocalRecord record) {
    return ProductSearchResult(
      productId: record.id,
      name: record.searchName ?? record.payload['name']?.toString() ?? '',
      sku: record.searchSku,
      barcode: record.searchBarcode,
      retailPrice: (record.payload['retail_price'] as num?)?.toDouble() ?? 0,
    );
  }
}
