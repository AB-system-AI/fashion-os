import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_text_field.dart';
import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/providers/inventory_providers.dart';

class BarcodeStockActionPage extends ConsumerStatefulWidget {
  const BarcodeStockActionPage({super.key});

  @override
  ConsumerState<BarcodeStockActionPage> createState() => _BarcodeStockActionPageState();
}

class _BarcodeStockActionPageState extends ConsumerState<BarcodeStockActionPage> {
  final _barcode = TextEditingController();
  final _warehouseId = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  String? _message;
  bool _busy = false;

  Future<void> _run({required bool receive}) async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    final qty = double.tryParse(_quantity.text) ?? 0;
    if (_barcode.text.trim().isEmpty || _warehouseId.text.trim().isEmpty || qty <= 0) return;

    setState(() {
      _busy = true;
      _message = null;
    });
    final service = ref.read(barcodeStockActionServiceProvider);
    final result = receive
        ? await service.receiveByBarcode(
            user: user,
            warehouseId: _warehouseId.text.trim(),
            barcode: _barcode.text.trim(),
            quantity: qty,
          )
        : await service.issueByBarcode(
            user: user,
            warehouseId: _warehouseId.text.trim(),
            barcode: _barcode.text.trim(),
            quantity: qty,
          );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = result.isSuccess
          ? 'Updated — on hand ${result.dataOrNull!.onHand}'
          : result.failureOrNull?.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canMove = ref.watch(permissionCheckProvider(InventoryPermissions.movement));
    if (!canMove) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: InventoryPermissions.movement));
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Barcode Stock Action')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            AppTextField(controller: _warehouseId, label: 'Warehouse ID'),
            const Gap(AppSpacing.md),
            AppTextField(controller: _barcode, label: 'Barcode'),
            const Gap(AppSpacing.md),
            AppTextField(controller: _quantity, label: 'Quantity', keyboardType: TextInputType.number),
            const Gap(AppSpacing.lg),
            if (_busy) const AppLoadingWidget() else ...[
              SemanticButton(label: 'Receive', icon: Icons.add, onPressed: () => _run(receive: true)),
              const Gap(AppSpacing.sm),
              SemanticButton(label: 'Issue', icon: Icons.remove, onPressed: () => _run(receive: false)),
            ],
            if (_message != null) ...[
              const Gap(AppSpacing.lg),
              Text(_message!, textAlign: TextAlign.center),
            ],
          ],
        ),
      ),
    );
  }
}
