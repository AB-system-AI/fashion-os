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
import 'package:fashion_pos_enterprise/features/customers/presentation/providers/customer_providers.dart';

class CreditPage extends ConsumerStatefulWidget {
  const CreditPage({super.key});

  @override
  ConsumerState<CreditPage> createState() => _CreditPageState();
}

class _CreditPageState extends ConsumerState<CreditPage> {
  final _customerId = TextEditingController();
  final _amount = TextEditingController(text: '25');

  @override
  void dispose() {
    _customerId.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _charge() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    final amount = double.tryParse(_amount.text) ?? 0;
    final result = await ref.read(customerCreditServiceProvider).charge(user: user, customerId: _customerId.text.trim(), amount: amount);
    _show(result.isSuccess ? 'Charged' : result.failureOrNull!.message);
  }

  void _show(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(permissionCheckProvider(CreditPermissions.manage))) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: CreditPermissions.manage));
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Customer Credit')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            AppTextField(controller: _customerId, label: 'Customer ID'),
            const Gap(AppSpacing.sm),
            AppTextField(controller: _amount, label: 'Amount', keyboardType: TextInputType.number),
            const Gap(AppSpacing.lg),
            SemanticButton(label: 'Charge Credit', onPressed: _charge),
          ],
        ),
      ),
    );
  }
}
