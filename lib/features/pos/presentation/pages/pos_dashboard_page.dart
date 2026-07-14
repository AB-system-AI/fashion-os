import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/pos/routing/pos_route_paths.dart';

class PosDashboardPage extends ConsumerWidget {
  const PosDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(SalePermissions.view));
    if (!canView) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: SalePermissions.view));
    }

    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 900 ? 3 : width >= 600 ? 2 : 1;

    return AppScaffold(
      appBar: const AppAppBar(title: Text('POS')),
      body: GridView.count(
        crossAxisCount: crossAxisCount,
        padding: const EdgeInsets.all(AppSpacing.lg),
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: width >= 600 ? 2.2 : 2.8,
        children: [
          _NavCard(icon: Icons.point_of_sale, title: 'Sales', route: PosRoutePaths.sales),
          _NavCard(icon: Icons.account_balance_wallet_outlined, title: 'Cash Session', route: PosRoutePaths.cashSession),
          _NavCard(icon: Icons.search, title: 'Product Search', route: PosRoutePaths.productSearch),
          _NavCard(icon: Icons.qr_code_scanner, title: 'Barcode Selling', route: PosRoutePaths.barcode),
          _NavCard(icon: Icons.shopping_cart_outlined, title: 'Cart', route: PosRoutePaths.cart),
          _NavCard(icon: Icons.person_outline, title: 'Customer', route: PosRoutePaths.customer),
          _NavCard(icon: Icons.payments_outlined, title: 'Payment', route: PosRoutePaths.payment),
          _NavCard(icon: Icons.receipt_long_outlined, title: 'Receipt', route: PosRoutePaths.receipt),
          _NavCard(icon: Icons.print_outlined, title: 'Reprint', route: PosRoutePaths.reprint),
          _NavCard(icon: Icons.pause_circle_outline, title: 'Suspend Sale', route: PosRoutePaths.suspend),
          _NavCard(icon: Icons.play_circle_outline, title: 'Resume Sale', route: PosRoutePaths.resume),
          _NavCard(icon: Icons.undo_outlined, title: 'Returns', route: PosRoutePaths.returns),
          _NavCard(icon: Icons.swap_horiz, title: 'Exchange', route: PosRoutePaths.exchange),
          _NavCard(icon: Icons.local_offer_outlined, title: 'Coupons', route: PosRoutePaths.coupons),
          _NavCard(icon: Icons.card_giftcard, title: 'Gift Receipt', route: PosRoutePaths.giftReceipt),
          _NavCard(icon: Icons.schedule_outlined, title: 'Layaway', route: PosRoutePaths.layaway),
          _NavCard(icon: Icons.swap_vert, title: 'Cash Movements', route: PosRoutePaths.cashMovements),
          _NavCard(icon: Icons.history, title: 'Cash History', route: PosRoutePaths.cashHistory),
          _NavCard(icon: Icons.assessment_outlined, title: 'Reports', route: PosRoutePaths.reports),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({required this.icon, required this.title, required this.route});

  final IconData icon;
  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(route),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
