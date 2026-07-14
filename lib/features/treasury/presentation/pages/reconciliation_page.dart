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
import 'package:fashion_pos_enterprise/features/treasury/presentation/providers/treasury_providers.dart';

class ReconciliationPage extends ConsumerStatefulWidget {
  const ReconciliationPage({super.key});

  @override
  ConsumerState<ReconciliationPage> createState() => _ReconciliationPageState();
}

class _ReconciliationPageState extends ConsumerState<ReconciliationPage> {
  List<BankReconciliation> _items = const [];
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
    final page = await ref.read(reconciliationServiceProvider).list(user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _items = page.items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(TreasuryPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: TreasuryPermissions.view));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Bank Reconciliation')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final r = _items[i];
                  return Card(
                    child: ListTile(
                      title: Text('Statement ${r.statementDate.toIso8601String().substring(0, 10)}'),
                      subtitle: Text('${r.status.value} · variance ${r.variance.toStringAsFixed(2)}'),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
