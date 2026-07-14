import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/features/assets/presentation/pages/asset_detail_page.dart';
import 'package:fashion_pos_enterprise/features/assets/presentation/pages/asset_list_page.dart';
import 'package:fashion_pos_enterprise/features/assets/presentation/pages/asset_reports_page.dart';
import 'package:fashion_pos_enterprise/features/assets/presentation/pages/assets_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/assets/presentation/pages/categories_page.dart';
import 'package:fashion_pos_enterprise/features/assets/presentation/pages/contracts_page.dart';
import 'package:fashion_pos_enterprise/features/assets/presentation/pages/depreciation_page.dart';
import 'package:fashion_pos_enterprise/features/assets/presentation/pages/maintenance_page.dart';
import 'package:fashion_pos_enterprise/features/assets/routing/assets_route_paths.dart';

List<RouteBase> buildAssetsRoutes() {
  return [
    GoRoute(
      path: AssetsRoutePaths.dashboard,
      name: AssetsRouteNames.dashboard,
      builder: (_, __) => const AssetsDashboardPage(),
      routes: [
        GoRoute(path: 'categories', name: AssetsRouteNames.categories, builder: (_, __) => const CategoriesPage()),
        GoRoute(path: 'list', name: AssetsRouteNames.list, builder: (_, __) => const AssetListPage()),
        GoRoute(path: 'maintenance', name: AssetsRouteNames.maintenance, builder: (_, __) => const MaintenancePage()),
        GoRoute(path: 'contracts', name: AssetsRouteNames.contracts, builder: (_, __) => const ContractsPage()),
        GoRoute(path: 'depreciation', name: AssetsRouteNames.depreciation, builder: (_, __) => const DepreciationPage()),
        GoRoute(path: 'reports', name: AssetsRouteNames.reports, builder: (_, __) => const AssetReportsPage()),
        GoRoute(
          path: ':id',
          name: AssetsRouteNames.detail,
          builder: (_, s) => AssetDetailPage(assetId: s.pathParameters['id']!),
        ),
      ],
    ),
  ];
}
