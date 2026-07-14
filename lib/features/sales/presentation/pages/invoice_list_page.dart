import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';

class InvoiceListPage extends ConsumerWidget {
  const InvoiceListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(permissionCheckProvider(SalesInvoicePermissions.create));
    if (!allowed) return const AppScaffold(body: PermissionDeniedWidget(permission: SalesInvoicePermissions.create));
    return const AppScaffold(
      appBar: AppAppBar(title: Text('Sales Invoices')),
      body: Center(child: Text('Invoice references linked to accounting journals')),
    );
  }
}
