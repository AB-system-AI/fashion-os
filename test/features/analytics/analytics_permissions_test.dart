import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';

void main() {
  test('analytics permission codes are stable', () {
    expect(AnalyticsPermissions.view, 'analytics.view');
    expect(AnalyticsPermissions.manage, 'analytics.manage');
    expect(DashboardPermissions.manage, 'dashboard.manage');
    expect(ReportPermissions.view, 'reports.view');
    expect(ReportPermissions.create, 'reports.create');
    expect(ReportPermissions.export, 'reports.export');
    expect(ReportPermissions.schedule, 'reports.schedule');
    expect(KpiPermissions.view, 'kpi.view');
    expect(ExecutiveDashboardPermissions.view, 'executive.dashboard');
  });
}
