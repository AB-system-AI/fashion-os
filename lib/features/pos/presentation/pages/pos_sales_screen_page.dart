import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/empty/app_empty_state.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/sale_line.dart';
import 'package:fashion_pos_enterprise/features/pos/presentation/providers/pos_providers.dart';

class PosSalesScreenPage extends ConsumerStatefulWidget {
  const PosSalesScreenPage({super.key});

  @override
  ConsumerState<PosSalesScreenPage> createState() => _PosSalesScreenPageState();
}

class _PosSalesScreenPageState extends ConsumerState<PosSalesScreenPage> {
  final _searchController = TextEditingController();
  List<SaleLine> _lines = [];
  String? _status;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    final results = await ref.read(posServiceProvider).searchProducts(user!.tenantId!, _searchController.text);
    if (!mounted) return;
    setState(() => _status = '${results.length} products found');
  }

  Future<void> _scanBarcode() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    final result = await ref.read(barcodeSaleServiceProvider).lineFromBarcode(
          tenantId: user!.tenantId!,
          barcode: _searchController.text.trim(),
        );
    if (!mounted) return;
    if (result.isSuccess) {
      setState(() => _lines = [..._lines, result.dataOrNull!]);
    } else {
      setState(() => _status = result.failureOrNull?.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = ref.watch(permissionCheckProvider(SalePermissions.create));
    if (!canCreate) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: SalePermissions.create));
    }

    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Sales')),
      body: isWide ? _buildWideLayout() : _buildNarrowLayout(),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildSearchPanel()),
        const VerticalDivider(width: 1),
        Expanded(flex: 3, child: _buildCartPanel()),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [_buildSearchPanel(), const SizedBox(height: AppSpacing.lg), _buildCartPanel()],
    );
  }

  Widget _buildSearchPanel() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search / Barcode',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: SemanticButton(label: 'Search', icon: Icons.search, onPressed: _search)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: SemanticButton(label: 'Scan', icon: Icons.qr_code_scanner, onPressed: _scanBarcode)),
            ],
          ),
          if (_status != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_status!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _buildCartPanel() {
    final subtotal = _lines.fold(0.0, (s, l) => s + l.lineTotal);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Cart (${_lines.length} items)', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _lines.isEmpty
                ? const AppEmptyState(message: 'Cart is empty')
                : ListView.builder(
                    itemCount: _lines.length,
                    itemBuilder: (_, i) {
                      final line = _lines[i];
                      return ListTile(
                        title: Text(line.productName),
                        subtitle: Text('${line.quantity} x ${line.unitPrice}'),
                        trailing: Text(line.lineTotal.toStringAsFixed(2)),
                      );
                    },
                  ),
          ),
          const Divider(),
          Text('Subtotal: ${subtotal.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
