abstract final class AssetsRoutePaths {
  static const dashboard = '/assets';
  static const categories = '/assets/categories';
  static const list = '/assets/list';
  static const maintenance = '/assets/maintenance';
  static const contracts = '/assets/contracts';
  static const depreciation = '/assets/depreciation';
  static const reports = '/assets/reports';

  static String detail(String id) => '/assets/$id';
}

abstract final class AssetsRouteNames {
  static const dashboard = 'assets-dashboard';
  static const categories = 'assets-categories';
  static const list = 'assets-list';
  static const detail = 'assets-detail';
  static const maintenance = 'assets-maintenance';
  static const contracts = 'assets-contracts';
  static const depreciation = 'assets-depreciation';
  static const reports = 'assets-reports';
}
