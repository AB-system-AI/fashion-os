abstract final class AnalyticsRoutePaths {
  static const hub = '/analytics';
  static const executive = '/analytics/executive';
  static const sales = '/analytics/sales';
  static const inventory = '/analytics/inventory';
  static const purchasing = '/analytics/purchasing';
  static const crm = '/analytics/crm';
  static const accounting = '/analytics/accounting';
  static const hr = '/analytics/hr';
  static const manufacturing = '/analytics/manufacturing';
  static const reports = '/reports';
  static const reportTemplates = '/reports/templates';
  static const scheduledReports = '/reports/scheduled';
  static const reportExport = '/reports/export';

  static String reportDetail(String id) => '/reports/$id';
}

abstract final class AnalyticsRouteNames {
  static const hub = 'analytics-hub';
  static const executive = 'analytics-executive';
  static const sales = 'analytics-sales';
  static const inventory = 'analytics-inventory';
  static const purchasing = 'analytics-purchasing';
  static const crm = 'analytics-crm';
  static const accounting = 'analytics-accounting';
  static const hr = 'analytics-hr';
  static const manufacturing = 'analytics-manufacturing';
  static const reports = 'reports-hub';
  static const reportDetail = 'report-detail';
  static const reportTemplates = 'report-templates';
  static const scheduledReports = 'scheduled-reports';
  static const reportExport = 'report-export';
}
