import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/inventory/presentation/pages/inventory_dashboard_page.dart';

void main() {
  testWidgets('inventory dashboard shows navigation when permitted', (tester) async {
    const user = AuthUser(
      userId: 'u1',
      email: 'a@b.com',
      emailVerified: true,
      tenantId: 't1',
      permissions: {'inventory.read'},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWithValue(user),
        ],
        child: const MaterialApp(home: InventoryDashboardPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Warehouses'), findsOneWidget);
    expect(find.text('Stock Levels'), findsOneWidget);
    expect(find.text('Transfers'), findsOneWidget);
  });
}
