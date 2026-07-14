import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';

class ReturnsPage extends ConsumerWidget {
  const ReturnsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(permissionCheckProvider(SalesReturnPermissions.manage));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: SalesReturnPermissions.manage));
    return const AppScaffold(
      appBar: AppAppBar(title: Text('Returns')),
      body: Center(child: Text('Create return requests from order detail')),
    );
  }
}

class ExchangesPage extends ConsumerWidget {
  const ExchangesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(permissionCheckProvider(SalesExchangePermissions.manage));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: SalesExchangePermissions.manage));
    return const AppScaffold(
      appBar: AppAppBar(title: Text('Exchanges')),
      body: Center(child: Text('Exchange requests with price difference settlement')),
    );
  }
}
