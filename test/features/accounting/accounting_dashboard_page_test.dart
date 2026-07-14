import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/accounting/presentation/pages/accounting_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';

void main() {
  testWidgets('Accounting dashboard shows navigation when permitted', (tester) async {
    const user = AuthUser(
      userId: 'u1',
      employeeId: 'e1',
      email: 'a@b.com',
      emailVerified: true,
      tenantId: 't1',
      permissions: {'accounting.view'},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentUserProvider.overrideWithValue(user)],
        child: const MaterialApp(home: AccountingDashboardPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Accounting'), findsOneWidget);
    expect(find.text('Chart of Accounts'), findsOneWidget);
    expect(find.text('Trial Balance'), findsOneWidget);
    expect(find.text('Journal Entries'), findsOneWidget);
  });
}
