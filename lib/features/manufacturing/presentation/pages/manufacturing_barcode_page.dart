import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_text_field.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/domain/services/manufacturing_services.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/providers/manufacturing_providers.dart';

class ManufacturingBarcodePage extends ConsumerStatefulWidget {
  const ManufacturingBarcodePage({super.key});

  @override
  ConsumerState<ManufacturingBarcodePage> createState() => _ManufacturingBarcodePageState();
}

class _ManufacturingBarcodePageState extends ConsumerState<ManufacturingBarcodePage> {
  final _controller = TextEditingController();
  String? _result;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    final barcode = _controller.text.trim();
    final parsed = ref.read(manufacturingBarcodeServiceProvider).parse(user: user, barcode: barcode);
    if (parsed.isFailure) {
      setState(() => _result = parsed.failureOrNull!.message);
      return;
    }
    final action = parsed.dataOrNull!;
    if (action.type == BarcodeActionType.productionLookup) {
      final order = await ref.read(manufacturingBarcodeServiceProvider).lookupProduction(user, action.reference);
      setState(() => _result = order.dataOrNull != null ? 'MO ${order.dataOrNull!.orderNumber} — ${order.dataOrNull!.status.name}' : 'Not found');
    } else if (action.type == BarcodeActionType.workOrderLookup) {
      final wo = await ref.read(manufacturingBarcodeServiceProvider).lookupWorkOrder(user, action.reference);
      setState(() => _result = wo.dataOrNull != null ? 'WO ${wo.dataOrNull!.workOrderNumber} — ${wo.dataOrNull!.status.name}' : 'Not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(ManufacturingPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: ManufacturingPermissions.view));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Barcode Actions')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Scan or enter MO: / WO: barcode'),
            const Gap(AppSpacing.md),
            AppTextField(controller: _controller, label: 'Barcode'),
            const Gap(AppSpacing.md),
            FilledButton(onPressed: _lookup, child: const Text('Lookup')),
            const Gap(AppSpacing.lg),
            if (_result != null) Text(_result!, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
