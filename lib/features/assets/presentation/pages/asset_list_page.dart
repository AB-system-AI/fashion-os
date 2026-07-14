import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/asset.dart';
import 'package:fashion_pos_enterprise/features/assets/presentation/providers/assets_providers.dart';
import 'package:fashion_pos_enterprise/features/assets/routing/assets_route_paths.dart';

class AssetListPage extends ConsumerStatefulWidget {
  const AssetListPage({super.key});

  @override
  ConsumerState<AssetListPage> createState() => _AssetListPageState();
}

class _AssetListPageState extends ConsumerState<AssetListPage> {
  List<Asset> _items = const [];
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
      _items = page.items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(AssetsPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: AssetsPermissions.view));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Asset Register')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) {
                  final a = _items[i];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.business_center),
                      title: Text(a.name),
                      subtitle: Text('${a.status.value} · Book: ${a.bookValue.toStringAsFixed(2)}'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(AssetsRoutePaths.detail(a.id)),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
