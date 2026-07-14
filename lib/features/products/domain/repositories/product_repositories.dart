import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/brand.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/category.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';

abstract class ProductRepository implements IRepository<Product> {
  Future<Product?> findBySku(String tenantId, String sku);
  Future<Product?> findByBarcode(String tenantId, String barcode);
}

abstract class CategoryRepository implements IRepository<Category> {
  Future<List<Category>> listTree(String tenantId);
}

abstract class BrandRepository implements IRepository<Brand> {}
