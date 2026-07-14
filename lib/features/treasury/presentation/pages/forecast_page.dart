import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/forecast.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/value_objects/treasury_value_objects.dart';
import 'package:fashion_pos_enterprise/features/treasury/presentation/providers/treasury_providers.dart';

class ForecastPage extends ConsumerStatefulWidget {
  const ForecastPage({super.key});

  @override
  ConsumerState<ForecastPage> createState() => _ForecastPageState();
}

class _ForecastPageState extends ConsumerState<ForecastPage> {
  List<CashForecast> _items = const [];
  LiquiditySnapshot? _liquidity;
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
    final page = await ref.read(forecastServiceProvider).list(user!.tenantId!);
    final liquidity = await ref.read(forecastServiceProvider).liquiditySnapshot(user.tenantId!);
    if (!mounted) return;
    setState(() {
      _items = page.items;
      _liquidity = liquidity;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(ForecastPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: ForecastPermissions.view));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Cash Forecast')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  if (_liquidity != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Net Liquidity', style: Theme.of(context).textTheme.titleMedium),
                            Text('${_liquidity!.netLiquidity.toStringAsFixed(2)} ${_liquidity!.currencyCode}'),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  ..._items.map(
                    (f) => Card(
                      child: ListTile(
                        title: Text(f.forecastDate.toIso8601String().substring(0, 10)),
                        subtitle: Text('${f.period.value} · ${f.projectedBalance.toStringAsFixed(2)}'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
