import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/entities/organization.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/enums/admin_enums.dart';

void main() {
  test('Company entity type name is stable', () {
    expect(Company.entityTypeName, 'admin_company');
  });

  test('Company toPayload includes status', () {
    final company = Company(
      id: 'c1',
      tenantId: 't1',
      name: 'Test Co',
      version: 1,
      createdAt: _t,
      updatedAt: _t,
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
      status: OrgUnitStatus.active,
    );
    expect(company.toPayload()['status'], 'active');
    expect(company.entityType, 'admin_company');
  });
}

final _t = DateTime.utc(2026, 1, 1);
