import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/pages/system_dashboard_page.dart';

void main() {
  testWidgets('System dashboard shows navigation when permitted', (tester) async {
    const user = AuthUser(
      userId: 'u1',
      employeeId: 'e1',
      email: 'a@b.com',
      emailVerified: true,
      tenantId: 't1',
      permissions: {'system.view'},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentUserProvider.overrideWithValue(user)],
        child: const MaterialApp(home: SystemDashboardPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('System Administration'), findsOneWidget);
    expect(find.text('Feature Flags'), findsOneWidget);
    expect(find.text('Audit Explorer'), findsOneWidget);
    expect(find.text('Security Center'), findsOneWidget);
  });
}
