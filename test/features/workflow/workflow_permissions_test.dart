import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';

void main() {
  test('workflow permission codes are stable', () {
    expect(WorkflowAdminPermissions.admin, 'workflow.admin');
    expect(ApprovalPermissions.view, 'approval.view');
    expect(ApprovalPermissions.manage, 'approval.manage');
    expect(NotificationCenterPermissions.view, 'notification.view');
    expect(NotificationCenterPermissions.manage, 'notification.manage');
  });
}
