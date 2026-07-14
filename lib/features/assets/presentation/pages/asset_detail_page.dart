import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/empty/app_empty_state.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/assets/domain/entities/asset.dart';
import 'package:fashion_pos_enterprise/features/assets/presentation/providers/assets_providers.dart';

class AssetDetailPage extends ConsumerStatefulWidget {
  const AssetDetailPage({super.key, required this.assetId});

  final String assetId;

  @override
  ConsumerState<AssetDetailPage> createState() => _AssetDetailPageState();
}

class _AssetDetailPageState extends ConsumerState<AssetDetailPage> {
  Asset? _asset;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    setState(() => _loading = true);
    final result = await ref.read(assetServiceProvider).getById(user: user, id: widget.assetId);
    if (!mounted) return;
    setState(() {
      _asset = result.dataOrNull;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(AssetsPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: AssetsPermissions.view));
    if (_loading) return const AppScaffold(body: AppLoadingWidget());
    final asset = _asset;
    if (asset == null) {
      return const AppScaffold(appBar: AppAppBar(title: Text('Asset Detail')), body: AppEmptyState(message: 'Asset not found'));
    }
    return AppScaffold(
      appBar: AppAppBar(title: Text(asset.name)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _InfoRow('Status', asset.status.value),
          _InfoRow('Tag', asset.assetTag ?? '—'),
          _InfoRow('Serial', asset.serialNumber ?? '—'),
          _InfoRow('Acquisition Cost', asset.acquisitionCost.toStringAsFixed(2)),
          _InfoRow('Book Value', asset.bookValue.toStringAsFixed(2)),
          _InfoRow('Depreciation', asset.accumulatedDepreciation.toStringAsFixed(2)),
          _InfoRow('Useful Life', '${asset.usefulLifeMonths} months'),
          _InfoRow('Method', asset.depreciationMethod.value),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: Theme.of(context).textTheme.labelMedium)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
