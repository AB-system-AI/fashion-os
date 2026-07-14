import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/admin/administration_engine.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/enums/admin_enums.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/value_objects/admin_value_objects.dart';

void main() {
  late AdministrationEngine engine;

  setUp(() => engine = AdministrationEngine());

  test('validateOrganization rejects empty name', () {
    final result = engine.validateOrganization(const OrganizationInput(name: ''));
    expect(result.isValid, isFalse);
  });

  test('validateTenant rejects user over limit', () {
    final result = engine.validateTenant(const TenantValidationInput(
      tenantId: 't1',
      currentUsers: 11,
      maxUsers: 10,
      usedStorageMb: 0,
      maxStorageMb: 1000,
    ));
    expect(result.isValid, isFalse);
  });

  test('validateRoleAssignment rejects duplicate permissions', () {
    final result = engine.validateRoleAssignment(const RoleAssignmentInput(
      roleId: 'r1',
      permissionCodes: ['admin.view', 'admin.view'],
    ));
    expect(result.isValid, isFalse);
  });

  test('validateLicense detects expired license', () {
    final result = engine.validateLicense(
      status: LicenseStatus.active,
      expiresAt: DateTime.utc(2020, 1, 1),
      now: DateTime.utc(2026, 1, 1),
    );
    expect(result.isValid, isFalse);
  });

  test('assessHealth returns degraded when errors present', () {
    final assessment = engine.assessHealth(
      openErrors: 5,
      pendingSyncItems: 0,
      storageUtilizationPercent: 50,
      maintenanceActive: false,
    );
    expect(assessment.status, HealthStatus.degraded);
    expect(assessment.issues, isNotEmpty);
  });

  test('calculateUsage returns utilization percent', () {
    final summary = engine.calculateUsage(
      activeUsers: 8,
      licensedUsers: 10,
      storageUsedMb: 500,
      storageLimitMb: 1000,
      apiCallsToday: 100,
      apiLimitDaily: 1000,
    );
    expect(summary.utilizationPercent, 80);
  });

  test('canTransitionOrgUnit allows active to inactive', () {
    expect(engine.canTransitionOrgUnit(OrgUnitStatus.active, OrgUnitStatus.inactive), isTrue);
  });
}
