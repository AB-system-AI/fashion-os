import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/hr/presentation/pages/hr_dashboard_page.dart';

void main() {
  testWidgets('HR dashboard shows navigation when permitted', (tester) async {
    const user = AuthUser(
      userId: 'u1',
      employeeId: 'e1',
      email: 'a@b.com',
      emailVerified: true,
      tenantId: 't1',
      permissions: {'hr.view'},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentUserProvider.overrideWithValue(user)],
        child: const MaterialApp(home: HrDashboardPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Human Resources'), findsOneWidget);
    expect(find.text('Employees'), findsOneWidget);
    expect(find.text('Payroll'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
  });
}
