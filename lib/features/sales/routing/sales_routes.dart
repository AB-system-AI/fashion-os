import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/features/sales/presentation/pages/delivery_list_page.dart';
import 'package:fashion_pos_enterprise/features/sales/presentation/pages/invoice_list_page.dart';
import 'package:fashion_pos_enterprise/features/sales/presentation/pages/quotation_detail_page.dart';
import 'package:fashion_pos_enterprise/features/sales/presentation/pages/quotation_list_page.dart';
import 'package:fashion_pos_enterprise/features/sales/presentation/pages/returns_exchanges_page.dart';
import 'package:fashion_pos_enterprise/features/sales/presentation/pages/sales_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/sales/presentation/pages/sales_order_detail_page.dart';
import 'package:fashion_pos_enterprise/features/sales/presentation/pages/sales_order_list_page.dart';
import 'package:fashion_pos_enterprise/features/sales/presentation/pages/sales_reports_page.dart';
import 'package:fashion_pos_enterprise/features/sales/presentation/pages/shipment_detail_page.dart';
import 'package:fashion_pos_enterprise/features/sales/presentation/pages/shipment_list_page.dart';
import 'package:fashion_pos_enterprise/features/sales/routing/sales_route_paths.dart';

List<RouteBase> buildSalesRoutes() {
  return [
    GoRoute(
      path: SalesRoutePaths.dashboard,
      name: SalesRouteNames.dashboard,
      builder: (_, __) => const SalesDashboardPage(),
      routes: [
        GoRoute(path: 'quotations', name: SalesRouteNames.quotations, builder: (_, __) => const QuotationListPage(), routes: [
          GoRoute(path: ':id', name: SalesRouteNames.quotationDetail, builder: (_, s) => QuotationDetailPage(quotationId: s.pathParameters['id']!)),
        ]),
        GoRoute(path: 'orders', name: SalesRouteNames.orders, builder: (_, __) => const SalesOrderListPage(), routes: [
          GoRoute(path: ':id', name: SalesRouteNames.orderDetail, builder: (_, s) => SalesOrderDetailPage(orderId: s.pathParameters['id']!)),
        ]),
        GoRoute(path: 'shipments', name: SalesRouteNames.shipments, builder: (_, __) => const ShipmentListPage(), routes: [
          GoRoute(path: ':id', name: SalesRouteNames.shipmentDetail, builder: (_, s) => ShipmentDetailPage(shipmentId: s.pathParameters['id']!)),
        ]),
        GoRoute(path: 'deliveries', name: SalesRouteNames.deliveries, builder: (_, __) => const DeliveryListPage()),
        GoRoute(path: 'invoices', name: SalesRouteNames.invoices, builder: (_, __) => const InvoiceListPage()),
        GoRoute(path: 'returns', name: SalesRouteNames.returns, builder: (_, __) => const ReturnsPage()),
        GoRoute(path: 'exchanges', name: SalesRouteNames.exchanges, builder: (_, __) => const ExchangesPage()),
        GoRoute(path: 'reports', name: SalesRouteNames.reports, builder: (_, __) => const SalesReportsPage()),
        GoRoute(path: 'picking', name: SalesRouteNames.picking, builder: (_, __) => const PickingPage()),
        GoRoute(path: 'packing', name: SalesRouteNames.packing, builder: (_, __) => const PackingPage()),
      ],
    ),
  ];
}
