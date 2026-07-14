abstract final class InventoryRoutePaths {
  static const dashboard = '/inventory';
  static const warehouses = '/inventory/warehouses';
  static String warehouseDetail(String id) => '/inventory/warehouses/$id';
  static const stock = '/inventory/stock';
  static const movements = '/inventory/movements';
  static const transfers = '/inventory/transfers';
  static String transferDetail(String id) => '/inventory/transfers/$id';
  static const counts = '/inventory/counts';
  static const barcode = '/inventory/barcode';
}

abstract final class InventoryRouteNames {
  static const dashboard = 'inventory';
  static const warehouses = 'inventory-warehouses';
  static const warehouseDetail = 'inventory-warehouse-detail';
  static const stock = 'inventory-stock';
  static const movements = 'inventory-movements';
  static const transfers = 'inventory-transfers';
  static const transferDetail = 'inventory-transfer-detail';
  static const counts = 'inventory-counts';
  static const barcode = 'inventory-barcode';
}
