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

class LoyaltyPage extends ConsumerStatefulWidget {
  const LoyaltyPage({super.key});

  @override
  ConsumerState<LoyaltyPage> createState() => _LoyaltyPageState();
}

class _LoyaltyPageState extends ConsumerState<LoyaltyPage> {
  final _customerId = TextEditingController();
  final _points = TextEditingController(text: '100');
  final _saleAmount = TextEditingController(text: '50');

  @override
  void dispose() {
    _customerId.dispose();
    _points.dispose();
    _saleAmount.dispose();
    super.dispose();
  }

  Future<void> _earn() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    final amount = double.tryParse(_saleAmount.text) ?? 0;
    final result = await ref.read(loyaltyServiceProvider).earnFromSale(user: user, customerId: _customerId.text.trim(), saleAmount: amount);
    _showResult(result.isSuccess ? 'Points earned' : result.failureOrNull!.message);
  }

  Future<void> _redeem() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    final pts = int.tryParse(_points.text) ?? 0;
    final result = await ref.read(loyaltyServiceProvider).redeem(user: user, customerId: _customerId.text.trim(), points: pts);
    _showResult(result.isSuccess ? 'Points redeemed' : result.failureOrNull!.message);
  }

  void _showResult(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(permissionCheckProvider(LoyaltyPermissions.manage))) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: LoyaltyPermissions.manage));
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Loyalty')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppTextField(controller: _customerId, label: 'Customer ID'),
          const Gap(AppSpacing.sm),
          AppTextField(controller: _saleAmount, label: 'Sale Amount', keyboardType: TextInputType.number),
          SemanticButton(label: 'Earn Points', onPressed: _earn),
          const Gap(AppSpacing.lg),
          AppTextField(controller: _points, label: 'Points to Redeem', keyboardType: TextInputType.number),
          SemanticButton(label: 'Redeem Points', onPressed: _redeem),
        ],
      ),
    );
  }
}
