import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/features/purchasing/presentation/pages/purchase_order_detail_page.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/pages/purchase_order_list_page.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/pages/purchase_return_list_page.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/pages/purchasing_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/pages/purchasing_reports_page.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/pages/receive_goods_page.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/pages/supplier_detail_page.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/pages/supplier_list_page.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/pages/supplier_statement_page.dart';
import 'package:fashion_pos_enterprise/features/purchasing/routing/purchasing_route_paths.dart';

List<RouteBase> buildPurchasingRoutes() {
  return [
    GoRoute(
      path: PurchasingRoutePaths.dashboard,
      name: PurchasingRouteNames.dashboard,
      builder: (context, state) => const PurchasingDashboardPage(),
      routes: [
        GoRoute(
          path: 'suppliers',
          name: PurchasingRouteNames.suppliers,
          builder: (context, state) => const SupplierListPage(),
          routes: [
            GoRoute(
              path: ':id',
              name: PurchasingRouteNames.supplierDetail,
              builder: (context, state) => SupplierDetailPage(supplierId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: 'orders',
          name: PurchasingRouteNames.orders,
          builder: (context, state) => const PurchaseOrderListPage(),
          routes: [
            GoRoute(
              path: ':id',
              name: PurchasingRouteNames.orderDetail,
              builder: (context, state) => PurchaseOrderDetailPage(orderId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: 'receive',
          name: PurchasingRouteNames.receive,
          builder: (context, state) => const ReceiveGoodsPage(),
        ),
        GoRoute(
          path: 'returns',
          name: PurchasingRouteNames.returns,
          builder: (context, state) => const PurchaseReturnListPage(),
        ),
        GoRoute(
          path: 'reports',
          name: PurchasingRouteNames.reports,
          builder: (context, state) => const PurchasingReportsPage(),
        ),
        GoRoute(
          path: 'statements/:id',
          name: PurchasingRouteNames.statement,
          builder: (context, state) => SupplierStatementPage(supplierId: state.pathParameters['id']!),
        ),
      ],
    ),
  ];
}
