import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/admin_dashboard_page.dart';

void main() {
  testWidgets('Admin dashboard shows navigation when permitted', (tester) async {
    const user = AuthUser(
      userId: 'u1',
      employeeId: 'e1',
      email: 'a@b.com',
      emailVerified: true,
      tenantId: 't1',
      permissions: {'admin.view'},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentUserProvider.overrideWithValue(user)],
        child: const MaterialApp(home: AdminDashboardPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Enterprise Administration'), findsOneWidget);
    expect(find.text('Organizations'), findsOneWidget);
    expect(find.text('Users'), findsOneWidget);
    expect(find.text('License'), findsOneWidget);
    expect(find.text('Audit Explorer'), findsOneWidget);
  });
}
