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
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_order.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/enums/purchasing_enums.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/providers/purchasing_providers.dart';

class ReceiveGoodsPage extends ConsumerStatefulWidget {
  const ReceiveGoodsPage({super.key});

  @override
  ConsumerState<ReceiveGoodsPage> createState() => _ReceiveGoodsPageState();
}

class _ReceiveGoodsPageState extends ConsumerState<ReceiveGoodsPage> {
  List<PurchaseOrder> _orders = [];
  bool _loading = true;
  final _poIdController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void dispose() {
    _poIdController.dispose();
    _barcodeController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    setState(() => _loading = true);
    final page = await ref.read(purchaseOrderServiceProvider).list(user: user!, tenantId: user.tenantId!);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _orders = page.items.where((o) => o.status.canReceive).toList();
    });
  }

  Future<void> _receiveByBarcode() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    final qty = double.tryParse(_qtyController.text) ?? 0;
    if (_poIdController.text.isEmpty || _barcodeController.text.isEmpty || qty <= 0) return;

    final result = await ref.read(barcodeReceivingServiceProvider).receiveByBarcode(
          user: user,
          purchaseOrderId: _poIdController.text.trim(),
          barcode: _barcodeController.text.trim(),
          quantity: qty,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.isSuccess ? 'Received successfully' : result.failureOrNull!.message),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final canReceive = ref.watch(permissionCheckProvider(PurchasePermissions.receive));
    if (!canReceive) {
      return const AppScaffold(
        body: PermissionDeniedWidget(permission: PurchasePermissions.receive),
      );
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Receive Goods')),
      body: _loading
          ? const AppLoadingWidget()
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text('Barcode Receiving', style: Theme.of(context).textTheme.titleMedium),
                  AppTextField(controller: _poIdController, label: 'Purchase Order ID'),
                  const Gap(AppSpacing.sm),
                  AppTextField(controller: _barcodeController, label: 'Barcode'),
                  const Gap(AppSpacing.sm),
                  AppTextField(controller: _qtyController, label: 'Quantity', keyboardType: TextInputType.number),
                  const Gap(AppSpacing.md),
                  SemanticButton(label: 'Scan & Receive', onPressed: _receiveByBarcode),
                  const Gap(AppSpacing.xl),
                  Text('Receivable Orders', style: Theme.of(context).textTheme.titleMedium),
                  ..._orders.map(
                    (o) => ListTile(
                      title: Text(o.poNumber),
                      subtitle: Text(o.status.value),
                      onTap: () => _poIdController.text = o.id,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
