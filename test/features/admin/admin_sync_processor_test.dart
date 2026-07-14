import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/features/admin/data/datasources/admin_remote_datasource.dart';
import 'package:fashion_pos_enterprise/features/admin/data/sync/admin_sync_processor.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/licensing.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/organization.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/settings.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/users_roles.dart';

void main() {
  test('admin sync processors map entity types to remote tables', () {
    final remote = AdminRemoteDataSource();
    expect(AdminSyncProcessor(remote: remote, entityTypeName: Company.entityTypeName, remoteTable: 'admin_companies').entityType, 'admin_company');
    expect(AdminSyncProcessor(remote: remote, entityTypeName: Branch.entityTypeName, remoteTable: 'admin_branches').entityType, 'admin_branch');
    expect(AdminSyncProcessor(remote: remote, entityTypeName: RoleTemplate.entityTypeName, remoteTable: 'admin_role_templates').entityType, 'admin_role_template');
    expect(AdminSyncProcessor(remote: remote, entityTypeName: TenantSettings.entityTypeName, remoteTable: 'admin_tenant_settings').entityType, 'admin_tenant_settings');
    expect(AdminSyncProcessor(remote: remote, entityTypeName: LicenseRecord.entityTypeName, remoteTable: 'admin_license_records').entityType, 'admin_license_record');
    expect(AdminSyncProcessor(remote: remote, entityTypeName: UsageSnapshot.entityTypeName, remoteTable: 'admin_usage_metrics').entityType, 'admin_usage_snapshot');
  });
}
