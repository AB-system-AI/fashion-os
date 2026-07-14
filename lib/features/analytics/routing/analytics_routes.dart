import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/features/analytics/domain/enums/analytics_enums.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/pages/analytics_hub_page.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/pages/module_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/pages/report_detail_page.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/pages/report_export_page.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/pages/report_templates_page.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/pages/reports_hub_page.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/pages/scheduled_reports_page.dart';
import 'package:fashion_pos_enterprise/features/analytics/routing/analytics_route_paths.dart';

List<RouteBase> buildAnalyticsRoutes() {
  return [
    GoRoute(
      path: AnalyticsRoutePaths.hub,
      name: AnalyticsRouteNames.hub,
      builder: (_, __) => const AnalyticsHubPage(),
      routes: [
        GoRoute(
          path: 'executive',
          name: AnalyticsRouteNames.executive,
          builder: (_, __) => const ModuleDashboardPage(
            type: DashboardType.executive,
            permission: ExecutiveDashboardPermissions.view,
          ),
        ),
        GoRoute(
          path: 'sales',
          name: AnalyticsRouteNames.sales,
          builder: (_, __) => const ModuleDashboardPage(
            type: DashboardType.sales,
            permission: AnalyticsPermissions.view,
          ),
        ),
        GoRoute(
          path: 'inventory',
          name: AnalyticsRouteNames.inventory,
          builder: (_, __) => const ModuleDashboardPage(
            type: DashboardType.inventory,
            permission: AnalyticsPermissions.view,
          ),
        ),
        GoRoute(
          path: 'purchasing',
          name: AnalyticsRouteNames.purchasing,
          builder: (_, __) => const ModuleDashboardPage(
            type: DashboardType.purchasing,
            permission: AnalyticsPermissions.view,
          ),
        ),
        GoRoute(
          path: 'crm',
          name: AnalyticsRouteNames.crm,
          builder: (_, __) => const ModuleDashboardPage(
            type: DashboardType.crm,
            permission: AnalyticsPermissions.view,
          ),
        ),
        GoRoute(
          path: 'accounting',
          name: AnalyticsRouteNames.accounting,
          builder: (_, __) => const ModuleDashboardPage(
            type: DashboardType.accounting,
            permission: AnalyticsPermissions.view,
          ),
        ),
        GoRoute(
          path: 'hr',
          name: AnalyticsRouteNames.hr,
          builder: (_, __) => const ModuleDashboardPage(
            type: DashboardType.hr,
            permission: AnalyticsPermissions.view,
          ),
        ),
        GoRoute(
          path: 'manufacturing',
          name: AnalyticsRouteNames.manufacturing,
          builder: (_, __) => const ModuleDashboardPage(
            type: DashboardType.manufacturing,
            permission: AnalyticsPermissions.view,
          ),
        ),
      ],
    ),
    GoRoute(
      path: AnalyticsRoutePaths.reports,
      name: AnalyticsRouteNames.reports,
      builder: (_, __) => const ReportsHubPage(),
      routes: [
        GoRoute(
          path: 'templates',
          name: AnalyticsRouteNames.reportTemplates,
          builder: (_, __) => const ReportTemplatesPage(),
        ),
        GoRoute(
          path: 'scheduled',
          name: AnalyticsRouteNames.scheduledReports,
          builder: (_, __) => const ScheduledReportsPage(),
        ),
        GoRoute(
          path: 'export',
          name: AnalyticsRouteNames.reportExport,
          builder: (_, __) => const ReportExportPage(),
        ),
        GoRoute(
          path: ':id',
          name: AnalyticsRouteNames.reportDetail,
          builder: (_, state) => ReportDetailPage(reportId: state.pathParameters['id']!),
        ),
      ],
    ),
  ];
}
