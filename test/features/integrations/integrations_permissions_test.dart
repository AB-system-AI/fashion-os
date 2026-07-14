import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';

void main() {
  test('integrations permission codes are stable', () {
    expect(IntegrationPermissions.view, 'integrations.view');
    expect(IntegrationPermissions.manage, 'integrations.manage');
    expect(WebhookPermissions.manage, 'webhook.manage');
    expect(ApiKeyPermissions.manage, 'apikey.manage');
    expect(ConnectorPermissions.manage, 'connector.manage');
  });
}
