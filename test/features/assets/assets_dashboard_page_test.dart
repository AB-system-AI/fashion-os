import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/assets/presentation/pages/assets_dashboard_page.dart';

void main() {
  testWidgets('Assets dashboard shows navigation when permitted', (tester) async {
    const user = AuthUser(
      userId: 'u1',
      employeeId: 'e1',
      email: 'a@b.com',
      emailVerified: true,
      tenantId: 't1',
      permissions: {'assets.view'},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentUserProvider.overrideWithValue(user)],
        child: const MaterialApp(home: AssetsDashboardPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Assets & Maintenance'), findsOneWidget);
    expect(find.text('Asset Register'), findsOneWidget);
    expect(find.text('Maintenance'), findsOneWidget);
    expect(find.text('Depreciation'), findsOneWidget);
  });
}
