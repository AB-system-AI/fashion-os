import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/treasury/domain/entities/cheques.dart';
import 'package:fashion_pos_enterprise/features/treasury/presentation/providers/treasury_providers.dart';

class ChequesPage extends ConsumerStatefulWidget {
  const ChequesPage({super.key});

  @override
  ConsumerState<ChequesPage> createState() => _ChequesPageState();
}

class _ChequesPageState extends ConsumerState<ChequesPage> {
  List<Cheque> _items = const [];
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
    final page = await ref.read(chequeServiceProvider).list(user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _items = page.items;
      _loading = false;
    });
  }

  Future<void> _createSample() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    await ref.read(chequeServiceProvider).issue(user: user, bankAccountId: 'bank-acct-1', amount: 500, payee: 'Vendor X');
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(TreasuryPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: TreasuryPermissions.view));
    final canManage = ref.watch(permissionCheckProvider(ChequePermissions.manage));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Cheques')),
      floatingActionButton: canManage ? FloatingActionButton.extended(onPressed: _createSample, icon: const Icon(Icons.add), label: const Text('Issue')) : null,
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final c = _items[i];
                  return Card(
                    child: ListTile(
                      title: Text(c.chequeNumber),
                      subtitle: Text('${c.payee} · ${c.status.value} · ${c.amount.toStringAsFixed(2)}'),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
