import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/asset.dart';
import 'package:fashion_pos_enterprise/features/assets/presentation/providers/assets_providers.dart';

class DepreciationPage extends ConsumerStatefulWidget {
  const DepreciationPage({super.key});

  @override
  ConsumerState<DepreciationPage> createState() => _DepreciationPageState();
}

class _DepreciationPageState extends ConsumerState<DepreciationPage> {
  List<Asset> _assets = const [];
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
    final page = await ref.read(assetServiceProvider).list(user!.tenantId!);
    if (!mounted) return;
    setState(() {
      _assets = page.items.where((a) => a.status != AssetStatus.disposed).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(AssetsPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: AssetsPermissions.view));
    final service = ref.read(depreciationServiceProvider);
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Depreciation')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _assets.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final a = _assets[i];
                  final schedule = service.scheduleForAsset(a, periods: 3);
                  final next = schedule.isNotEmpty ? schedule.first.depreciationAmount : 0.0;
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.trending_down),
                      title: Text(a.name),
                      subtitle: Text('Book ${a.bookValue.toStringAsFixed(2)} · Next ${next.toStringAsFixed(2)}'),
                      trailing: Text(a.depreciationMethod.value),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
