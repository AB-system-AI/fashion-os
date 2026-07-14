import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/pages/workflow_dashboard_page.dart';

void main() {
  testWidgets('Workflow dashboard shows navigation when permitted', (tester) async {
    const user = AuthUser(
      userId: 'u1',
      employeeId: 'e1',
      email: 'a@b.com',
      emailVerified: true,
      tenantId: 't1',
      permissions: {'workflow.admin'},
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [currentUserProvider.overrideWithValue(user)],
        child: const MaterialApp(home: WorkflowDashboardPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Workflows'), findsOneWidget);
    expect(find.text('Approvals'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Approval Templates'), findsOneWidget);
    expect(find.text('Escalation Rules'), findsOneWidget);
  });
}
