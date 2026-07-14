abstract final class PurchasingRoutePaths {
  static const dashboard = '/purchasing';
  static const suppliers = '/purchasing/suppliers';
  static const orders = '/purchasing/orders';
  static const receive = '/purchasing/receive';
  static const returns = '/purchasing/returns';
  static const reports = '/purchasing/reports';

  static String supplierDetail(String id) => '/purchasing/suppliers/$id';
  static String orderDetail(String id) => '/purchasing/orders/$id';
  static String statement(String supplierId) => '/purchasing/statements/$supplierId';
}

abstract final class PurchasingRouteNames {
  static const dashboard = 'purchasing';
  static const suppliers = 'purchasing-suppliers';
  static const supplierDetail = 'purchasing-supplier-detail';
  static const orders = 'purchasing-orders';
  static const orderDetail = 'purchasing-order-detail';
  static const receive = 'purchasing-receive';
  static const returns = 'purchasing-returns';
  static const statement = 'purchasing-statement';
  static const reports = 'purchasing-reports';
}
