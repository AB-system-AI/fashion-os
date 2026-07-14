import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/presentation/pages/manufacturing_dashboard_page.dart';

void main() {
  testWidgets('Manufacturing dashboard shows navigation when permitted', (tester) async {
    const user = AuthUser(
      userId: 'u1',
      employeeId: 'e1',
      email: 'a@b.com',
      emailVerified: true,
      tenantId: 't1',
      permissions: {'manufacturing.view'},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentUserProvider.overrideWithValue(user)],
        child: const MaterialApp(home: ManufacturingDashboardPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Manufacturing'), findsOneWidget);
    expect(find.text('BOM List'), findsOneWidget);
    expect(find.text('Production Orders'), findsOneWidget);
    expect(find.text('Work Orders'), findsOneWidget);
    expect(find.text('Quality'), findsOneWidget);
  });
}
