import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';

void main() {
  test('admin permission codes are stable', () {
    expect(EnterpriseAdminPermissions.view, 'admin.view');
    expect(EnterpriseAdminPermissions.manage, 'admin.manage');
    expect(OrganizationPermissions.manage, 'org.manage');
    expect(TenantSettingsPermissions.settings, 'tenant.settings');
    expect(UserAdminPermissions.admin, 'user.admin');
    expect(RoleAdminPermissions.admin, 'role.admin');
    expect(AdminPermissions.manage, 'admin.manage');
  });
}
