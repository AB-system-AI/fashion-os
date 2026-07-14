import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/features/inventory/presentation/pages/barcode_stock_action_page.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/pages/inventory_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/pages/stock_count_page.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/pages/stock_list_page.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/pages/stock_movement_page.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/pages/transfer_detail_page.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/pages/transfer_list_page.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/pages/warehouse_detail_page.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/pages/warehouse_list_page.dart';
import 'package:fashion_pos_enterprise/features/inventory/routing/inventory_route_paths.dart';

List<RouteBase> buildInventoryRoutes() {
  return [
    GoRoute(
      path: InventoryRoutePaths.dashboard,
      name: InventoryRouteNames.dashboard,
      builder: (context, state) => const InventoryDashboardPage(),
      routes: [
        GoRoute(
          path: 'warehouses',
          name: InventoryRouteNames.warehouses,
          builder: (context, state) => const WarehouseListPage(),
          routes: [
            GoRoute(
              path: ':id',
              name: InventoryRouteNames.warehouseDetail,
              builder: (context, state) => WarehouseDetailPage(warehouseId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: 'stock',
          name: InventoryRouteNames.stock,
          builder: (context, state) => const StockListPage(),
        ),
        GoRoute(
          path: 'movements',
          name: InventoryRouteNames.movements,
          builder: (context, state) => const StockMovementPage(),
        ),
        GoRoute(
          path: 'transfers',
          name: InventoryRouteNames.transfers,
          builder: (context, state) => const TransferListPage(),
          routes: [
            GoRoute(
              path: ':id',
              name: InventoryRouteNames.transferDetail,
              builder: (context, state) => TransferDetailPage(transferId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: 'counts',
          name: InventoryRouteNames.counts,
          builder: (context, state) => const StockCountPage(),
        ),
        GoRoute(
          path: 'barcode',
          name: InventoryRouteNames.barcode,
          builder: (context, state) => const BarcodeStockActionPage(),
        ),
      ],
    ),
  ];
}
