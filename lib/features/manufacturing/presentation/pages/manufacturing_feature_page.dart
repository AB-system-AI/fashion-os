import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/empty/app_empty_state.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/enums/manufacturing_enums.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/providers/manufacturing_providers.dart';

class ManufacturingFeaturePage extends ConsumerStatefulWidget {
  const ManufacturingFeaturePage({
    super.key,
    required this.title,
    required this.description,
    required this.permission,
    this.showBoms = false,
    this.showProduction = false,
    this.showQuality = false,
  });

  final String title;
  final String description;
  final String permission;
  final bool showBoms;
  final bool showProduction;
  final bool showQuality;

  @override
  ConsumerState<ManufacturingFeaturePage> createState() => _ManufacturingFeaturePageState();
}

class _ManufacturingFeaturePageState extends ConsumerState<ManufacturingFeaturePage> {
  String? _summary;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    setState(() => _loading = true);

    if (widget.showBoms) {
      final page = await ref.read(bomServiceProvider).list(user!.tenantId!);
      if (mounted) setState(() => _summary = '${page.items.length} bills of material loaded offline');
    } else if (widget.showProduction) {
      final orders = await ref.read(productionOrderServiceProvider).listByStatus(user!.tenantId!, ProductionStatus.inProgress);
      if (mounted) setState(() => _summary = '${orders.length} production orders in progress');
    } else if (widget.showQuality) {
      final inspections = await ref.read(qualityRepositoryProvider).listAll(user!.tenantId!);
      if (mounted) setState(() => _summary = '${inspections.length} quality inspections');
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(widget.permission));
    if (!allowed) {
      return AppScaffold(body: PermissionDeniedWidget(permission: widget.permission));
    }

    return AppScaffold(
      appBar: AppAppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.description, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.xl),
            if (_loading) const LinearProgressIndicator(),
            if (_summary != null) Text(_summary!, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.lg),
            const AppEmptyState(message: 'Offline-first manufacturing data syncs automatically when online.'),
          ],
        ),
      ),
    );
  }
}
