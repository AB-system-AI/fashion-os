abstract final class CustomerRoutePaths {
  static const dashboard = '/customers';
  static const list = '/customers/list';
  static const create = '/customers/new';
  static const loyalty = '/customers/loyalty';
  static const wallet = '/customers/wallet';
  static const credit = '/customers/credit';
  static const reports = '/customers/reports';

  static String detail(String id) => '/customers/$id';
}

abstract final class CustomerRouteNames {
  static const dashboard = 'customers';
  static const list = 'customers-list';
  static const detail = 'customers-detail';
  static const create = 'customers-create';
  static const loyalty = 'customers-loyalty';
  static const wallet = 'customers-wallet';
  static const credit = 'customers-credit';
  static const reports = 'customers-reports';
}
