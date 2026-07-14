import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/cash_session.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/enums/pos_enums.dart';
import 'package:fashion_pos_enterprise/features/pos/presentation/providers/pos_providers.dart';

class PosCashSessionPage extends ConsumerStatefulWidget {
  const PosCashSessionPage({super.key});

  @override
  ConsumerState<PosCashSessionPage> createState() => _PosCashSessionPageState();
}

class _PosCashSessionPageState extends ConsumerState<PosCashSessionPage> {
  final _floatController = TextEditingController(text: '100');
  final _actualController = TextEditingController();
  CashSession? _session;
  String? _message;

  @override
  void dispose() {
    _floatController.dispose();
    _actualController.dispose();
    super.dispose();
  }

  Future<void> _openSession() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    final result = await ref.read(cashDrawerServiceProvider).openSession(
          user: user,
          storeId: user.storeIds.isNotEmpty ? user.storeIds.first : 'default-store',
          registerId: 'register-1',
          openingFloat: double.tryParse(_floatController.text) ?? 0,
        );
    if (!mounted) return;
    if (result.isSuccess) {
      final s = result.dataOrNull!;
      setState(() {
        _session = s;
        _message = 'Session ${s.sessionNumber} opened';
      });
    } else {
      setState(() => _message = result.failureOrNull?.message);
    }
  }

  Future<void> _closeSession() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || _session == null) return;
    final result = await ref.read(cashDrawerServiceProvider).closeSession(
          user: user,
          session: _session!,
          actualCash: double.tryParse(_actualController.text) ?? 0,
        );
    if (!mounted) return;
    if (result.isSuccess) {
      final s = result.dataOrNull!;
      setState(() {
        _session = s;
        _message = 'Session closed. Difference: ${s.cashDifference}';
      });
    } else {
      setState(() => _message = result.failureOrNull?.message);
    }
  }

  Future<void> _recordMovement(CashMovementType type) async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || _session == null) return;
    final result = await ref.read(cashDrawerServiceProvider).recordMovement(
          user: user,
          session: _session!,
          type: type,
          amount: 50,
          notes: type.value,
        );
    if (!mounted) return;
    if (result.isSuccess) {
      setState(() => _message = 'Movement recorded: ${type.value}');
    } else {
      setState(() => _message = result.failureOrNull?.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCash = ref.watch(permissionCheckProvider(SalePermissions.cash));
    if (!canCash) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: SalePermissions.cash));
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Cash Session')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (_session == null) ...[
            TextField(
              controller: _floatController,
              decoration: const InputDecoration(labelText: 'Opening Float', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.md),
            SemanticButton(label: 'Open Drawer', icon: Icons.lock_open, onPressed: _openSession),
          ] else ...[
            _InfoTile('Session', _session!.sessionNumber),
            _InfoTile('Status', _session!.status.value),
            _InfoTile('Expected Cash', _session!.expectedCash.toStringAsFixed(2)),
            _InfoTile('Total Sales', _session!.totalSales.toStringAsFixed(2)),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                SemanticButton(label: 'Safe Drop', onPressed: () => _recordMovement(CashMovementType.safeDrop)),
                SemanticButton(label: 'Cash In', onPressed: () => _recordMovement(CashMovementType.cashIn)),
                SemanticButton(label: 'Cash Out', onPressed: () => _recordMovement(CashMovementType.cashOut)),
                SemanticButton(label: 'Expense', onPressed: () => _recordMovement(CashMovementType.expense)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _actualController,
              decoration: const InputDecoration(labelText: 'Actual Cash Count', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: AppSpacing.md),
            SemanticButton(label: 'Close Drawer', icon: Icons.lock, onPressed: _closeSession),
          ],
          if (_message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(_message!),
          ],
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(width: 140, child: Text(label, style: Theme.of(context).textTheme.labelLarge)),
          Text(value),
        ],
      ),
    );
  }
}
