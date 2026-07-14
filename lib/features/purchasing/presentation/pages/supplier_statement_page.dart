import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier_payment.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/providers/purchasing_providers.dart';

class SupplierStatementPage extends ConsumerStatefulWidget {
  const SupplierStatementPage({required this.supplierId, super.key});

  final String supplierId;

  @override
  ConsumerState<SupplierStatementPage> createState() => _SupplierStatementPageState();
}

class _SupplierStatementPageState extends ConsumerState<SupplierStatementPage> {
  SupplierStatement? _statement;
  List<SupplierPayment> _payments = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    setState(() => _loading = true);
    final result = await ref.read(supplierFinancialServiceProvider).generateStatement(
          user: user,
          supplierId: widget.supplierId,
        );
    final payments = await ref.read(supplierFinancialServiceProvider).transactionHistory(
          user.tenantId!,
          widget.supplierId,
        );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.isFailure) {
        _error = result.failureOrNull?.message;
      } else {
        _statement = result.dataOrNull;
        _payments = payments;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final canView = ref.watch(permissionCheckProvider(SupplierPermissions.view));
    if (!canView) {
      return const AppScaffold(
        body: PermissionDeniedWidget(permission: SupplierPermissions.view),
      );
    }

    final s = _statement;
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Supplier Statement')),
      body: _loading
          ? const AppLoadingWidget()
          : _error != null
              ? AppErrorWidget(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      Text('Opening: ${s!.openingBalance.toStringAsFixed(2)}'),
                      Text('Closing: ${s.closingBalance.toStringAsFixed(2)}'),
                      const Gap(AppSpacing.lg),
                      Text('Transactions', style: Theme.of(context).textTheme.titleMedium),
                      ...s.entries.map(
                        (e) => ListTile(
                          dense: true,
                          title: Text(e.type.value),
                          subtitle: Text(e.reference ?? ''),
                          trailing: Text(e.amount.toStringAsFixed(2)),
                        ),
                      ),
                      const Gap(AppSpacing.lg),
                      Text('Payments', style: Theme.of(context).textTheme.titleMedium),
                      ..._payments.map(
                        (p) => ListTile(
                          dense: true,
                          title: Text(p.type.value),
                          trailing: Text(p.amount.toStringAsFixed(2)),
                        ),
                      ),
                      const Gap(AppSpacing.lg),
                      SemanticButton(label: 'Refresh Statement', onPressed: _load),
                    ],
                  ),
                ),
    );
  }
}
