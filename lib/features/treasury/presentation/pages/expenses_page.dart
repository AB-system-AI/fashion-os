import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/expenses.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/value_objects/treasury_value_objects.dart';
import 'package:fashion_pos_enterprise/features/treasury/presentation/providers/treasury_providers.dart';

class ExpensesPage extends ConsumerStatefulWidget {
  const ExpensesPage({super.key});

  @override
  ConsumerState<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends ConsumerState<ExpensesPage> {
  List<ExpenseRequest> _items = const [];
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
    final page = await ref.read(expenseServiceProvider).list(user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _items = page.items;
      _loading = false;
    });
  }

  Future<void> _createSample() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    await ref.read(expenseServiceProvider).create(
          user: user,
          input: const ExpenseInput(description: 'Office supplies', amount: 75, category: 'Operations'),
        );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(TreasuryPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: TreasuryPermissions.view));
    final canManage = ref.watch(permissionCheckProvider(ExpensePermissions.manage));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Expenses')),
      floatingActionButton: canManage ? FloatingActionButton.extended(onPressed: _createSample, icon: const Icon(Icons.add), label: const Text('New')) : null,
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final e = _items[i];
                  return Card(
                    child: ListTile(
                      title: Text(e.requestNumber),
                      subtitle: Text('${e.status.value} · ${e.amount.toStringAsFixed(2)}'),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
