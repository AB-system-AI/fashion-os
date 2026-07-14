import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';

void main() {
  test('assets permission codes are stable', () {
    expect(AssetsPermissions.view, 'assets.view');
    expect(AssetsPermissions.manage, 'assets.manage');
    expect(AssetMaintenancePermissions.view, 'assets.maintenance.view');
    expect(AssetMaintenancePermissions.manage, 'assets.maintenance.manage');
    expect(DepreciationPermissions.manage, 'depreciation.manage');
    expect(DisposalPermissions.manage, 'disposal.manage');
  });
}
