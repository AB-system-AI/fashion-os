import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/purchase_order.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/enums/purchasing_enums.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/providers/purchasing_providers.dart';

class PurchaseOrderDetailPage extends ConsumerStatefulWidget {
  const PurchaseOrderDetailPage({required this.orderId, super.key});

  final String orderId;

  @override
  ConsumerState<PurchaseOrderDetailPage> createState() => _PurchaseOrderDetailPageState();
}

class _PurchaseOrderDetailPageState extends ConsumerState<PurchaseOrderDetailPage> {
  PurchaseOrder? _order;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    final result = await ref.read(purchaseOrderServiceProvider).getById(widget.orderId, user: user);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.isFailure) {
        _error = result.failureOrNull?.message;
      } else {
        _order = result.dataOrNull;
      }
    });
  }

  Future<void> _action(Future<Result<PurchaseOrder>> Function() fn) async {
    final result = await fn();
    if (!mounted) return;
    if (result.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.failureOrNull!.message)));
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final o = _order;
    final canApprove = ref.watch(permissionCheckProvider(PurchasePermissions.approve));
    final canReceive = ref.watch(permissionCheckProvider(PurchasePermissions.receive));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Purchase Order')),
      body: _loading
          ? const AppLoadingWidget()
          : _error != null
              ? AppErrorWidget(message: _error!, onRetry: _load)
              : Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: ListView(
                    children: [
                      Text(o!.poNumber, style: Theme.of(context).textTheme.headlineSmall),
                      Text('Status: ${o.status.value}'),
                      Text('Supplier: ${o.supplierId}'),
                      Text('Warehouse: ${o.warehouseId}'),
                      Text('Total: ${o.grandTotal.toStringAsFixed(2)} ${o.currency}'),
                      const Gap(AppSpacing.lg),
                      Text('Lines', style: Theme.of(context).textTheme.titleMedium),
                      ...o.lines.map(
                        (l) => ListTile(
                          dense: true,
                          title: Text('Product ${l.productId}'),
                          subtitle: Text(
                            'Qty ${l.quantity} · Received ${l.receivedQuantity} · Remaining ${l.remainingQuantity}',
                          ),
                        ),
                      ),
                      const Gap(AppSpacing.lg),
                      if (user != null && o.status == PurchaseOrderStatus.draft)
                        SemanticButton(
                          label: 'Submit for Approval',
                          onPressed: () => _action(
                            () => ref.read(purchaseOrderServiceProvider).submitForApproval(user: user, order: o),
                          ),
                        ),
                      if (user != null && canApprove && o.status == PurchaseOrderStatus.pendingApproval)
                        SemanticButton(
                          label: 'Approve',
                          onPressed: () => _action(
                            () => ref.read(purchaseOrderServiceProvider).approve(user: user, order: o),
                          ),
                        ),
                      if (user != null && canApprove && o.status == PurchaseOrderStatus.approved)
                        SemanticButton(
                          label: 'Send to Supplier',
                          onPressed: () => _action(
                            () => ref.read(purchaseOrderServiceProvider).send(user: user, order: o),
                          ),
                        ),
                      if (user != null && canReceive && o.status.canReceive)
                        SemanticButton(
                          label: 'Receive All Remaining',
                          onPressed: () async {
                            final quantities = {
                              for (final l in o.lines) l.id: l.remainingQuantity,
                            };
                            final result = await ref.read(purchaseReceiptServiceProvider).receive(
                                  user: user,
                                  purchaseOrderId: o.id,
                                  quantitiesByLineId: quantities,
                                );
                            if (!mounted) return;
                            if (result.isFailure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result.failureOrNull!.message)),
                              );
                            }
                            await _load();
                          },
                        ),
                    ],
                  ),
                ),
    );
  }
}
