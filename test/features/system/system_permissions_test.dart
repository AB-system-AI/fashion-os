import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';

void main() {
  test('system permission codes are stable', () {
    expect(SystemPermissions.view, 'system.view');
    expect(SystemPermissions.manage, 'system.manage');
    expect(AdminPermissions.manage, 'admin.manage');
    expect(AuditExplorerPermissions.explore, 'audit.explore');
    expect(FeatureFlagPermissions.manage, 'featureflag.manage');
    expect(SecurityPermissions.manage, 'security.manage');
    expect(SystemMaintenancePermissions.manage, 'system.maintenance.manage');
  });
}
