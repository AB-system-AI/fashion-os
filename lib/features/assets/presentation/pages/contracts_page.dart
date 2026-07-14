import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/contracts.dart';
import 'package:fashion_pos_enterprise/features/assets/presentation/providers/assets_providers.dart';

class ContractsPage extends ConsumerStatefulWidget {
  const ContractsPage({super.key});

  @override
  ConsumerState<ContractsPage> createState() => _ContractsPageState();
}

class _ContractsPageState extends ConsumerState<ContractsPage> {
  List<ServiceContract> _contracts = const [];
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
    final contracts = await ref.read(serviceContractRepositoryProvider).listActive(user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _contracts = contracts;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(AssetsPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: AssetsPermissions.view));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Contracts & Warranties')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _contracts.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final c = _contracts[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.assignment),
                      title: Text(c.name),
                      subtitle: Text('${c.status.value} · Annual ${c.annualCost.toStringAsFixed(2)}'),
                      trailing: Text(c.endDate?.toLocal().toString().split(' ').first ?? '—'),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
