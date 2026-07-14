import 'dart:convert';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';
import 'package:fashion_pos_enterprise/features/products/domain/repositories/product_repositories.dart';

class ProductRepositoryImpl extends BaseLocalRepository<Product> implements ProductRepository {
  ProductRepositoryImpl({
    required AppDatabase database,
    required SyncQueueWriter syncQueue,
  })  : _database = database,
        super(database: database, entityType: Product.entityTypeName, syncQueue: syncQueue);

  final AppDatabase _database;

  @override
  Product mapFromLocalRecord(LocalRecord record) {
    return Product.fromPayload(record.payload, record);
  }

  @override
  LocalRecord mapToLocalRecord(Product entity) {
    return LocalRecord(
      id: entity.id,
      tenantId: entity.tenantId,
      entityType: entity.entityType,
      storeId: entity.storeId,
      payload: entity.toPayload(),
      version: entity.version,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      syncStatus: entity.syncStatus,
      isDirty: entity.isDirty,
      searchName: entity.name,
      searchSku: entity.sku,
      searchBarcode: entity.barcode,
    );
  }

  @override
  Future<Product?> findBySku(String tenantId, String sku) async {
    final record = await _database.syncableRecordDao.getPage(
      RepositoryQuery(tenantId: tenantId, entityType: Product.entityTypeName, pageSize: 200),
    );
    for (final row in record) {
      if (row.searchSku == sku) return mapFromLocalRecord(row);
    }
    return null;
  }

  @override
  Future<Product?> findByBarcode(String tenantId, String barcode) async {
    final record = await _database.syncableRecordDao.getByBarcode(
      tenantId: tenantId,
      barcode: barcode,
      entityType: Product.entityTypeName,
    );
    return record == null ? null : mapFromLocalRecord(record);
  }
}
