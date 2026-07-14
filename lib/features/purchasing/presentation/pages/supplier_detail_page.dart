import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

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
import 'package:fashion_pos_enterprise/features/purchasing/domain/entities/supplier.dart';
import 'package:fashion_pos_enterprise/features/purchasing/presentation/providers/purchasing_providers.dart';
import 'package:fashion_pos_enterprise/features/purchasing/routing/purchasing_route_paths.dart';

class SupplierDetailPage extends ConsumerStatefulWidget {
  const SupplierDetailPage({required this.supplierId, super.key});

  final String supplierId;

  @override
  ConsumerState<SupplierDetailPage> createState() => _SupplierDetailPageState();
}

class _SupplierDetailPageState extends ConsumerState<SupplierDetailPage> {
  Supplier? _supplier;
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
    final result = await ref.read(supplierServiceProvider).getById(widget.supplierId, user: user);
    final timeline = await ref.read(auditServiceProvider).getEntityTimeline(
          entityType: Supplier.entityTypeName,
          entityId: widget.supplierId,
        );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _timeline = timeline;
      if (result.isFailure) {
        _error = result.failureOrNull?.message;
      } else {
        _supplier = result.dataOrNull;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = _supplier;
    final canUpdate = ref.watch(permissionCheckProvider(SupplierPermissions.update));

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Supplier')),
      body: _loading
          ? const AppLoadingWidget()
          : _error != null
              ? AppErrorWidget(message: _error!, onRetry: _load)
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s!.companyName, style: Theme.of(context).textTheme.headlineSmall),
                      Text('Code: ${s.supplierCode}'),
                      Text('Balance: ${s.currentBalance.toStringAsFixed(2)} / Credit: ${s.creditLimit.toStringAsFixed(2)}'),
                      if (s.email != null) Text('Email: ${s.email}'),
                      if (s.phone != null) Text('Phone: ${s.phone}'),
                      const Gap(AppSpacing.lg),
                      SemanticButton(
                        label: 'View Statement',
                        onPressed: () => context.push(PurchasingRoutePaths.statement(s.id)),
                      ),
                      if (canUpdate && !s.active) ...[
                        const Gap(AppSpacing.sm),
                        SemanticButton(
                          label: 'Reactivate',
                          onPressed: () async {
                            final user = ref.read(authControllerProvider).user;
                            if (user == null) return;
                            await ref.read(supplierServiceProvider).update(
                                  user: user,
                                  supplier: s.copyWith(active: true),
                                  previous: s,
                                );
                            await _load();
                          },
                        ),
                      ],
                      const Gap(AppSpacing.xl),
                      Text('Timeline', style: Theme.of(context).textTheme.titleMedium),
                      AuditTimelineWidget(entries: _timeline),
                    ],
                  ),
                ),
    );
  }
}
