import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/features/manufacturing/presentation/pages/bom_list_page.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/pages/manufacturing_barcode_page.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/pages/manufacturing_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/pages/manufacturing_feature_page.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/pages/manufacturing_reports_page.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/pages/production_order_detail_page.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/pages/production_order_list_page.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/pages/work_order_list_page.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/routing/manufacturing_route_paths.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';

List<RouteBase> buildManufacturingRoutes() {
  return [
    GoRoute(
      path: ManufacturingRoutePaths.dashboard,
      name: ManufacturingRouteNames.dashboard,
      builder: (_, __) => const ManufacturingDashboardPage(),
      routes: [
        GoRoute(
          path: 'bom',
          name: ManufacturingRouteNames.bom,
          builder: (_, __) => const BomListPage(),
        ),
        GoRoute(
          path: 'production',
          name: ManufacturingRouteNames.production,
          builder: (_, __) => const ProductionOrderListPage(),
          routes: [
            GoRoute(
              path: ':id',
              name: ManufacturingRouteNames.productionDetail,
              builder: (_, state) => ProductionOrderDetailPage(orderId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: 'work-orders',
          name: ManufacturingRouteNames.workOrders,
          builder: (_, __) => const WorkOrderListPage(),
        ),
        GoRoute(
          path: 'work-centers',
          name: ManufacturingRouteNames.workCenters,
          builder: (_, __) => const ManufacturingFeaturePage(
            title: 'Work Centers',
            description: 'Work centers and machines.',
            permission: ManufacturingPermissions.manage,
          ),
        ),
        GoRoute(
          path: 'planning',
          name: ManufacturingRouteNames.planning,
          builder: (_, __) => const ManufacturingFeaturePage(
            title: 'Capacity Planning',
            description: 'MRP and capacity analysis.',
            permission: PlanningPermissions.manage,
          ),
        ),
        GoRoute(
          path: 'schedule',
          name: ManufacturingRouteNames.schedule,
          builder: (_, __) => const ManufacturingFeaturePage(
            title: 'Production Schedule',
            description: 'Scheduled production by work center.',
            permission: PlanningPermissions.manage,
          ),
        ),
        GoRoute(
          path: 'quality',
          name: ManufacturingRouteNames.quality,
          builder: (_, __) => const ManufacturingFeaturePage(
            title: 'Quality Inspections',
            description: 'Pass, fail, hold, rework, and scrap.',
            permission: QualityPermissions.manage,
            showQuality: true,
          ),
        ),
        GoRoute(
          path: 'maintenance',
          name: ManufacturingRouteNames.maintenance,
          builder: (_, __) => const ManufacturingFeaturePage(
            title: 'Maintenance',
            description: 'Machine maintenance requests.',
            permission: MaintenancePermissions.manage,
          ),
        ),
        GoRoute(
          path: 'barcode',
          name: ManufacturingRouteNames.barcode,
          builder: (_, __) => const ManufacturingBarcodePage(),
        ),
        GoRoute(
          path: 'reports',
          name: ManufacturingRouteNames.reports,
          builder: (_, __) => const ManufacturingReportsPage(),
        ),
      ],
    ),
  ];
}
