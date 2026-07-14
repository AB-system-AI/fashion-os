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
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/inventory_transfer.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/enums/inventory_enums.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/providers/inventory_providers.dart';

class TransferDetailPage extends ConsumerStatefulWidget {
  const TransferDetailPage({required this.transferId, super.key});

  final String transferId;

  @override
  ConsumerState<TransferDetailPage> createState() => _TransferDetailPageState();
}

class _TransferDetailPageState extends ConsumerState<TransferDetailPage> {
  InventoryTransfer? _transfer;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    final result = await ref.read(inventoryTransferServiceProvider).getById(widget.transferId, user: user);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.isFailure) {
        _error = result.failureOrNull?.message;
      } else {
        _transfer = result.dataOrNull;
      }
    });
  }

  Future<void> _action(Future<Result<InventoryTransfer>> Function() fn) async {
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
    final t = _transfer;
    final canApprove = ref.watch(permissionCheckProvider(InventoryPermissions.transferApprove));
    final canReceive = ref.watch(permissionCheckProvider(InventoryPermissions.transferReceive));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Transfer')),
      body: _loading
          ? const AppLoadingWidget()
          : _error != null
              ? AppErrorWidget(message: _error!, onRetry: _load)
              : Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${t!.status.value}', style: Theme.of(context).textTheme.titleLarge),
                      Text('From: ${t.fromWarehouseId}'),
                      Text('To: ${t.toWarehouseId}'),
                      Text('Lines: ${t.lines.length}'),
                      const Gap(AppSpacing.lg),
                      if (user != null && t.status == TransferStatus.draft)
                        SemanticButton(
                          label: 'Submit for Approval',
                          onPressed: () => _action(
                            () => ref.read(inventoryTransferServiceProvider).submitForApproval(user: user, transfer: t),
                          ),
                        ),
                      if (user != null && canApprove && t.status == TransferStatus.pendingApproval) ...[
                        SemanticButton(
                          label: 'Approve',
                          onPressed: () => _action(
                            () => ref.read(inventoryTransferServiceProvider).approve(user: user, transfer: t),
                          ),
                        ),
                        const Gap(AppSpacing.sm),
                        SemanticButton(
                          label: 'Ship',
                          onPressed: () => _action(
                            () => ref.read(inventoryTransferServiceProvider).ship(user: user, transfer: t),
                          ),
                        ),
                      ],
                      if (user != null && canReceive && t.status == TransferStatus.shipped)
                        SemanticButton(
                          label: 'Receive',
                          onPressed: () => _action(
                            () => ref.read(inventoryTransferServiceProvider).receive(user: user, transfer: t),
                          ),
                        ),
                      if (user != null && canReceive && t.status == TransferStatus.received)
                        SemanticButton(
                          label: 'Complete',
                          onPressed: () => _action(
                            () => ref.read(inventoryTransferServiceProvider).complete(user: user, transfer: t),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}
