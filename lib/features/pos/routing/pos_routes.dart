import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/features/pos/presentation/pages/pos_cash_session_page.dart';
import 'package:fashion_pos_enterprise/features/pos/presentation/pages/pos_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/pos/presentation/pages/pos_feature_page.dart';
import 'package:fashion_pos_enterprise/features/pos/presentation/pages/pos_sales_screen_page.dart';
import 'package:fashion_pos_enterprise/features/pos/routing/pos_route_paths.dart';

List<RouteBase> buildPosRoutes() {
  return [
    GoRoute(
      path: PosRoutePaths.dashboard,
      name: PosRouteNames.dashboard,
      builder: (_, __) => const PosDashboardPage(),
      routes: [
        GoRoute(path: 'sales', name: PosRouteNames.sales, builder: (_, __) => const PosSalesScreenPage()),
        GoRoute(path: 'cash-session', name: PosRouteNames.cashSession, builder: (_, __) => const PosCashSessionPage()),
        GoRoute(
          path: 'cash-session/open',
          name: PosRouteNames.openDrawer,
          builder: (_, __) => const PosCashSessionPage(),
        ),
        GoRoute(
          path: 'cash-session/close',
          name: PosRouteNames.closeDrawer,
          builder: (_, __) => const PosCashSessionPage(),
        ),
        GoRoute(
          path: 'search',
          name: PosRouteNames.productSearch,
          builder: (_, __) => const PosSalesScreenPage(),
        ),
        GoRoute(
          path: 'barcode',
          name: PosRouteNames.barcode,
          builder: (_, __) => const PosSalesScreenPage(),
        ),
        GoRoute(path: 'cart', name: PosRouteNames.cart, builder: (_, __) => const PosSalesScreenPage()),
        GoRoute(
          path: 'customer',
          name: PosRouteNames.customer,
          builder: (_, __) => const PosFeaturePage(
            title: 'Customer Selection',
            description: 'Attach customer for loyalty, wallet, and credit.',
            permission: SalePermissions.view,
          ),
        ),
        GoRoute(
          path: 'payment',
          name: PosRouteNames.payment,
          builder: (_, __) => const PosFeaturePage(
            title: 'Payment',
            description: 'Cash, card, wallet, gift card, and split payments.',
            permission: SalePermissions.payment,
          ),
        ),
        GoRoute(
          path: 'receipt',
          name: PosRouteNames.receipt,
          builder: (_, __) => const PosFeaturePage(
            title: 'Receipt Preview',
            description: 'Thermal, A4, PDF, and digital receipts.',
            permission: SalePermissions.print,
          ),
        ),
        GoRoute(
          path: 'receipt/reprint',
          name: PosRouteNames.reprint,
          builder: (_, __) => const PosFeaturePage(
            title: 'Reprint Receipt',
            description: 'Reprint with audit trail.',
            permission: ReceiptPermissions.reprint,
          ),
        ),
        GoRoute(
          path: 'suspend',
          name: PosRouteNames.suspend,
          builder: (_, __) => const PosFeaturePage(title: 'Suspend Sale', description: 'Park sale for later.'),
        ),
        GoRoute(
          path: 'resume',
          name: PosRouteNames.resume,
          builder: (_, __) => const PosFeaturePage(title: 'Resume Sale', description: 'Restore suspended sales.'),
        ),
        GoRoute(
          path: 'returns',
          name: PosRouteNames.returns,
          builder: (_, __) => const PosFeaturePage(
            title: 'Returns',
            description: 'Full and partial returns with stock restore.',
            permission: SalePermissions.refund,
          ),
        ),
        GoRoute(
          path: 'exchange',
          name: PosRouteNames.exchange,
          builder: (_, __) => const PosFeaturePage(
            title: 'Exchange',
            description: 'Return items and create new sale.',
            permission: SalePermissions.exchange,
          ),
        ),
        GoRoute(
          path: 'coupons',
          name: PosRouteNames.coupons,
          builder: (_, __) => const PosFeaturePage(
            title: 'Coupons',
            description: 'Apply percentage, fixed, BOGO coupons.',
            permission: CouponPermissions.manage,
          ),
        ),
        GoRoute(
          path: 'gift-receipt',
          name: PosRouteNames.giftReceipt,
          builder: (_, __) => const PosFeaturePage(
            title: 'Gift Receipt',
            description: 'Print gift receipt without prices.',
            permission: GiftReceiptPermissions.create,
          ),
        ),
        GoRoute(
          path: 'layaway',
          name: PosRouteNames.layaway,
          builder: (_, __) => const PosFeaturePage(
            title: 'Layaway',
            description: 'Deposit, schedule, pickup, cancel.',
            permission: LayawayPermissions.manage,
          ),
        ),
        GoRoute(
          path: 'cash-movements',
          name: PosRouteNames.cashMovements,
          builder: (_, __) => const PosCashSessionPage(),
        ),
        GoRoute(
          path: 'cash-history',
          name: PosRouteNames.cashHistory,
          builder: (_, __) => const PosFeaturePage(
            title: 'Cash History',
            description: 'Session and movement history.',
            permission: SalePermissions.cash,
          ),
        ),
        GoRoute(
          path: 'reports',
          name: PosRouteNames.reports,
          builder: (_, __) => const PosFeaturePage(
            title: 'POS Reports',
            description: 'Daily sales, payment methods, cashier performance.',
            permission: SalePermissions.view,
          ),
        ),
      ],
    ),
  ];
}
