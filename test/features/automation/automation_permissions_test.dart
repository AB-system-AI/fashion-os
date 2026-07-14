import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';

void main() {
  test('automation permission codes are stable', () {
    expect(AutomationPermissions.view, 'automation.view');
    expect(AutomationPermissions.manage, 'automation.manage');
    expect(WorkflowPermissions.manage, 'workflow.manage');
    expect(RulePermissions.manage, 'rule.manage');
    expect(SchedulerPermissions.manage, 'scheduler.manage');
    expect(ApprovalWorkflowPermissions.manage, 'automation.approval.manage');
    expect(AiPermissions.view, 'ai.view');
  });
}
