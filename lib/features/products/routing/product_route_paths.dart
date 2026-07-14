abstract final class ProductRoutePaths {
  static const list = '/products';
  static const create = '/products/new';
  static String detail(String id) => '/products/$id';
  static String edit(String id) => '/products/$id/edit';
  static String variants(String id) => '/products/$id/variants';
  static String barcodeLabels(String id) => '/products/$id/labels';
  static const categories = '/products/categories';
  static String categoryCreate = '/products/categories/new';
  static String categoryEdit(String id) => '/products/categories/$id/edit';
  static const brands = '/products/brands';
  static const brandCreate = '/products/brands/new';
  static String brandEdit(String id) => '/products/brands/$id/edit';
  static const import = '/products/import';
}

abstract final class ProductRouteNames {
  static const list = 'products';
  static const create = 'product-create';
  static const detail = 'product-detail';
  static const edit = 'product-edit';
  static const variants = 'product-variants';
  static const barcodeLabels = 'product-barcode-labels';
  static const categories = 'categories';
  static const categoryCreate = 'category-create';
  static const categoryEdit = 'category-edit';
  static const brands = 'brands';
  static const brandCreate = 'brand-create';
  static const brandEdit = 'brand-edit';
  static const import = 'product-import';
}
