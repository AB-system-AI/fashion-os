abstract final class SalesRoutePaths {
  static const dashboard = '/sales';
  static const quotations = '/sales/quotations';
  static const orders = '/sales/orders';
  static const shipments = '/sales/shipments';
  static const deliveries = '/sales/deliveries';
  static const invoices = '/sales/invoices';
  static const returns = '/sales/returns';
  static const exchanges = '/sales/exchanges';
  static const reports = '/sales/reports';
  static const picking = '/sales/picking';
  static const packing = '/sales/packing';

  static String quotationDetail(String id) => '/sales/quotations/$id';
  static String orderDetail(String id) => '/sales/orders/$id';
  static String shipmentDetail(String id) => '/sales/shipments/$id';
}

abstract final class SalesRouteNames {
  static const dashboard = 'sales-dashboard';
  static const quotations = 'sales-quotations';
  static const quotationDetail = 'sales-quotation-detail';
  static const orders = 'sales-orders';
  static const orderDetail = 'sales-order-detail';
  static const shipments = 'sales-shipments';
  static const shipmentDetail = 'sales-shipment-detail';
  static const deliveries = 'sales-deliveries';
  static const invoices = 'sales-invoices';
  static const returns = 'sales-returns';
  static const exchanges = 'sales-exchanges';
  static const reports = 'sales-reports';
  static const picking = 'sales-picking';
  static const packing = 'sales-packing';
}
