import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';

class DeliveryListPage extends ConsumerWidget {
  const DeliveryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(permissionCheckProvider(DeliveryPermissions.manage));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: DeliveryPermissions.manage));
    return const AppScaffold(
      appBar: AppAppBar(title: Text('Deliveries')),
      body: Center(child: Text('Delivery tracking — create from dispatched shipments')),
    );
  }
}
