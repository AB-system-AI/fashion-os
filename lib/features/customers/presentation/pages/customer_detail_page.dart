import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_providers.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/catalog/audit_timeline_widget.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer.dart';
import 'package:fashion_pos_enterprise/features/customers/presentation/providers/customer_providers.dart';

class CustomerDetailPage extends ConsumerStatefulWidget {
  const CustomerDetailPage({required this.customerId, super.key});
  final String customerId;

  @override
  ConsumerState<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends ConsumerState<CustomerDetailPage> {
  Customer? _customer;
  bool _loading = true;
  String? _error;
  List<AuditEntry> _timeline = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    final result = await ref.read(customerServiceProvider).getById(widget.customerId, user: user);
    final audit = await ref.read(auditServiceProvider).getEntityTimeline(
          entityType: Customer.entityTypeName,
          entityId: widget.customerId,
        );
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.isFailure) {
        _error = result.failureOrNull?.message;
      } else {
        _customer = result.dataOrNull;
        _timeline = audit;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = _customer;
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Customer')),
      body: _loading
          ? const AppLoadingWidget()
          : _error != null
              ? AppErrorWidget(message: _error!, onRetry: _load)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c!.fullName, style: Theme.of(context).textTheme.headlineSmall),
                      Text('Code: ${c.customerCode}'),
                      if (c.email != null) Text('Email: ${c.email}'),
                      if (c.phone != null || c.mobile != null) Text('Phone: ${c.phone ?? c.mobile}'),
                      Text('Loyalty: ${c.loyaltyPoints} pts (${c.loyaltyTier ?? 'standard'})'),
                      Text('Wallet: ${c.walletBalance.toStringAsFixed(2)}'),
                      Text('Credit: ${c.outstandingCredit.toStringAsFixed(2)} / ${c.creditLimit.toStringAsFixed(2)}'),
                      if (c.tags.isNotEmpty) Text('Tags: ${c.tags.join(', ')}'),
                      const Gap(AppSpacing.lg),
                      SemanticButton(label: 'Enroll Loyalty', onPressed: () async {
                        final user = ref.read(authControllerProvider).user;
                        if (user == null) return;
                        await ref.read(loyaltyServiceProvider).enroll(user: user, customerId: c.id);
                        await _load();
                      }),
                      const Gap(AppSpacing.xl),
                      Text('Audit Timeline', style: Theme.of(context).textTheme.titleMedium),
                      AuditTimelineWidget(entries: _timeline),
                    ],
                  ),
                ),
    );
  }
}
