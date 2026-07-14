import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/treasury/presentation/pages/treasury_dashboard_page.dart';

void main() {
  testWidgets('Treasury dashboard shows navigation when permitted', (tester) async {
    const user = AuthUser(
      userId: 'u1',
      employeeId: 'e1',
      email: 'a@b.com',
      emailVerified: true,
      tenantId: 't1',
      permissions: {'treasury.view'},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentUserProvider.overrideWithValue(user)],
        child: const MaterialApp(home: TreasuryDashboardPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Treasury'), findsOneWidget);
    expect(find.text('Cash Management'), findsOneWidget);
    expect(find.text('Bank Management'), findsOneWidget);
    expect(find.text('Reconciliation'), findsOneWidget);
    expect(find.text('Forecast'), findsOneWidget);
  });
}
