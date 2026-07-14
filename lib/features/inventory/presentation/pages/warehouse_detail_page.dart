import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/warehouse.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/providers/inventory_providers.dart';

class WarehouseDetailPage extends ConsumerStatefulWidget {
  const WarehouseDetailPage({required this.warehouseId, super.key});

  final String warehouseId;

  @override
  ConsumerState<WarehouseDetailPage> createState() => _WarehouseDetailPageState();
}

class _WarehouseDetailPageState extends ConsumerState<WarehouseDetailPage> {
  Warehouse? _warehouse;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    final result = await ref.read(warehouseServiceProvider).getById(widget.warehouseId, user: user);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.isFailure) {
        _error = result.failureOrNull?.message;
      } else {
        _warehouse = result.dataOrNull;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final w = _warehouse;
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Warehouse')),
      body: _loading
          ? const AppLoadingWidget()
          : _error != null
              ? AppErrorWidget(message: _error!, onRetry: _load)
              : Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(w!.name, style: Theme.of(context).textTheme.headlineSmall),
                      if (w.code != null) Text('Code: ${w.code}'),
                      if (w.storeId != null) Text('Store: ${w.storeId}'),
                      if (w.address != null) Text('Address: ${w.address}'),
                      Text('Status: ${w.isActive ? 'Active' : 'Archived'}'),
                    ],
                  ),
                ),
    );
  }
}
