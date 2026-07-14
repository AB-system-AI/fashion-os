import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/syncable_record.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/sync/sync_queue_writer.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/brand.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/category.dart';
import 'package:fashion_pos_enterprise/features/products/domain/repositories/product_repositories.dart';

class BrandRepositoryImpl extends BaseLocalRepository<Brand> implements BrandRepository {
  BrandRepositoryImpl({
    required AppDatabase database,
    required SyncQueueWriter syncQueue,
  }) : super(database: database, entityType: Brand.entityTypeName, syncQueue: syncQueue);

  @override
  Brand mapFromLocalRecord(LocalRecord record) => Brand.fromPayload(record.payload, record);

  @override
  LocalRecord mapToLocalRecord(Brand entity) {
    return LocalRecord(
      id: entity.id,
      tenantId: entity.tenantId,
      entityType: entity.entityType,
      payload: entity.toPayload(),
      version: entity.version,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      syncStatus: entity.syncStatus,
      isDirty: entity.isDirty,
      searchName: entity.name,
    );
  }
}

class CategoryRepositoryImpl extends BaseLocalRepository<Category> implements CategoryRepository {
  CategoryRepositoryImpl({
    required AppDatabase database,
    required SyncQueueWriter syncQueue,
  }) : super(database: database, entityType: Category.entityTypeName, syncQueue: syncQueue);

  @override
  Category mapFromLocalRecord(LocalRecord record) => Category.fromPayload(record.payload, record);

  @override
  LocalRecord mapToLocalRecord(Category entity) {
    return LocalRecord(
      id: entity.id,
      tenantId: entity.tenantId,
      entityType: entity.entityType,
      payload: entity.toPayload(),
      version: entity.version,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      deletedAt: entity.deletedAt,
      syncStatus: entity.syncStatus,
      isDirty: entity.isDirty,
      searchName: entity.name,
    );
  }

  @override
  Future<List<Category>> listTree(String tenantId) async {
    final page = await getPage(RepositoryQuery(tenantId: tenantId, pageSize: 1000, sortBy: 'sort_order'));
    return page.items;
  }
}
