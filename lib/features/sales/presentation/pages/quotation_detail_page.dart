import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/sales/domain/enums/sales_enums.dart';
import 'package:fashion_pos_enterprise/features/sales/presentation/providers/sales_providers.dart';

class QuotationDetailPage extends ConsumerStatefulWidget {
  const QuotationDetailPage({required this.quotationId, super.key});

  final String quotationId;

  @override
  ConsumerState<QuotationDetailPage> createState() => _QuotationDetailPageState();
}

class _QuotationDetailPageState extends ConsumerState<QuotationDetailPage> {
  dynamic _quotation;
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
    final q = await ref.read(quotationRepositoryProvider).getById(widget.quotationId, tenantId: user!.tenantId);
    if (!mounted) return;
    setState(() {
      _quotation = q;
      _loading = false;
    });
  }

  Future<void> _accept() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || _quotation == null) return;
    await ref.read(quotationServiceProvider).transition(user: user, quotation: _quotation, to: QuotationStatus.accepted);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final allowed = ref.watch(permissionCheckProvider(SalesOmsPermissions.view));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: SalesOmsPermissions.view));
    return AppScaffold(
      appBar: AppAppBar(title: Text(_quotation?.quotationNumber ?? 'Quotation')),
      body: _loading
          ? const AppLoadingWidget()
          : _quotation == null
              ? const AppErrorWidget(message: 'Not found')
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    ListTile(title: const Text('Status'), trailing: Text(_quotation.status.value)),
                    ListTile(title: const Text('Total'), trailing: Text(_quotation.grandTotal.toStringAsFixed(2))),
                    if (_quotation.status == QuotationStatus.sent)
                      FilledButton(onPressed: _accept, child: const Text('Accept quotation')),
                  ],
                ),
    );
  }
}
