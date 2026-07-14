import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_text_field.dart';
import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer.dart';
import 'package:fashion_pos_enterprise/features/customers/presentation/providers/customer_providers.dart';
import 'package:fashion_pos_enterprise/features/customers/routing/customer_route_paths.dart';

class CustomerFormPage extends ConsumerStatefulWidget {
  const CustomerFormPage({super.key});

  @override
  ConsumerState<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends ConsumerState<CustomerFormPage> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || _firstName.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final now = DateTime.now().toUtc();
    final result = await ref.read(customerServiceProvider).create(
          user: user,
          draft: Customer(
            id: '',
            tenantId: user.tenantId!,
            customerCode: '',
            firstName: _firstName.text.trim(),
            lastName: _lastName.text.trim().isEmpty ? null : _lastName.text.trim(),
            phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
            email: _email.text.trim().isEmpty ? null : _email.text.trim(),
            version: 1,
            createdAt: now,
            updatedAt: now,
            syncStatus: LocalSyncStatus.pending,
            isDirty: true,
          ),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result.isFailure) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.failureOrNull!.message)));
      return;
    }
    context.go(CustomerRoutePaths.detail(result.dataOrNull!.id));
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = ref.watch(permissionCheckProvider(CustomerPermissions.create));
    if (!canCreate) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: CustomerPermissions.create));
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('New Customer')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            AppTextField(controller: _firstName, label: 'First Name'),
            const Gap(AppSpacing.sm),
            AppTextField(controller: _lastName, label: 'Last Name'),
            const Gap(AppSpacing.sm),
            AppTextField(controller: _phone, label: 'Phone'),
            const Gap(AppSpacing.sm),
            AppTextField(controller: _email, label: 'Email'),
            const Gap(AppSpacing.lg),
            SemanticButton(label: _saving ? 'Saving...' : 'Create Customer', onPressed: _saving ? null : _save),
          ],
        ),
      ),
    );
  }
}
