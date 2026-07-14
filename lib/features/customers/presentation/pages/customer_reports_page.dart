import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/services/customer_analytics_service.dart';
import 'package:fashion_pos_enterprise/features/customers/presentation/providers/customer_providers.dart';

class CustomerReportsPage extends ConsumerStatefulWidget {
  const CustomerReportsPage({super.key});

  @override
  ConsumerState<CustomerReportsPage> createState() => _CustomerReportsPageState();
}

class _CustomerReportsPageState extends ConsumerState<CustomerReportsPage> {
  List<CustomerValueSummary> _top = [];
  int _inactive = 0;
  int _birthdays = 0;
  double _walletTotal = 0;
  double _creditTotal = 0;
  int _loyaltyTotal = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    setState(() => _loading = true);
    final analytics = ref.read(customerAnalyticsServiceProvider);
    final top = await analytics.topCustomers(user!.tenantId!);
    final inactive = await analytics.inactiveCustomers(user.tenantId!);
    final birthdays = await analytics.birthdayCustomers(user.tenantId!);
    final wallet = await analytics.totalWalletBalances(user.tenantId!);
    final credit = await analytics.totalOutstandingCredit(user.tenantId!);
    final loyalty = await analytics.totalLoyaltyPoints(user.tenantId!);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _top = top;
      _inactive = inactive.length;
      _birthdays = birthdays.length;
      _walletTotal = wallet;
      _creditTotal = credit;
      _loyaltyTotal = loyalty;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(permissionCheckProvider(CustomerPermissions.view))) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: CustomerPermissions.view));
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Customer Reports')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Card(child: ListTile(title: const Text('Inactive Customers'), trailing: Text('$_inactive'))),
                  Card(child: ListTile(title: const Text('Birthdays Today'), trailing: Text('$_birthdays'))),
                  Card(child: ListTile(title: const Text('Total Wallet'), trailing: Text(_walletTotal.toStringAsFixed(2)))),
                  Card(child: ListTile(title: const Text('Outstanding Credit'), trailing: Text(_creditTotal.toStringAsFixed(2)))),
                  Card(child: ListTile(title: const Text('Total Loyalty Points'), trailing: Text('$_loyaltyTotal'))),
                  const Gap(AppSpacing.lg),
                  Text('Top Customers', style: Theme.of(context).textTheme.titleMedium),
                  ..._top.map((s) => ListTile(title: Text(s.customer.fullName), trailing: Text(s.lifetimeValue.toStringAsFixed(2)))),
                ],
              ),
            ),
    );
  }
}
