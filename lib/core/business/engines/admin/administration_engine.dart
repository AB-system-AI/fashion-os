import 'package:fashion_pos_enterprise/features/admin/domain/enums/admin_enums.dart';
import 'package:fashion_pos_enterprise/features/admin/domain/value_objects/admin_value_objects.dart';

class ValidationResult {
  const ValidationResult({required this.isValid, this.errors = const []});

  final bool isValid;
  final List<String> errors;
}

class HealthAssessment {
  const HealthAssessment({
    required this.status,
    required this.score,
    required this.issues,
  });

  final HealthStatus status;
  final double score;
  final List<String> issues;
}

class UsageSummary {
  const UsageSummary({
    required this.activeUsers,
    required this.storageUsedMb,
    required this.apiCallsToday,
    required this.utilizationPercent,
  });

  final int activeUsers;
  final double storageUsedMb;
  final int apiCallsToday;
  final double utilizationPercent;
}

class LicenseValidation {
  const LicenseValidation({
    required this.isValid,
    required this.daysRemaining,
    this.reason,
  });

  final bool isValid;
  final int daysRemaining;
  final String? reason;
}

/// Pure enterprise administration rules: org structure, tenant config, RBAC, licensing, health, usage.
class AdministrationEngine {
  ValidationResult validateOrganization(OrganizationInput input) {
    final errors = <String>[];
    if (input.name.trim().isEmpty) errors.add('Organization name is required');
    if (input.code != null && input.code!.length > 32) errors.add('Organization code must be 32 characters or fewer');
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  ValidationResult validateTenant(TenantValidationInput input) {
    final errors = <String>[];
    if (input.tenantId.trim().isEmpty) errors.add('Tenant ID is required');
    if (input.maxUsers > 0 && input.currentUsers > input.maxUsers) {
      errors.add('User count exceeds tenant limit (${input.maxUsers})');
    }
    if (input.maxStorageMb > 0 && input.usedStorageMb > input.maxStorageMb) {
      errors.add('Storage usage exceeds tenant limit (${input.maxStorageMb} MB)');
    }
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  ValidationResult validateRoleAssignment(RoleAssignmentInput input) {
    final errors = <String>[];
    if (input.roleId.trim().isEmpty) errors.add('Role is required');
    if (input.permissionCodes.isEmpty) errors.add('At least one permission is required');
    final seen = <String>{};
    for (final code in input.permissionCodes) {
      if (!seen.add(code)) errors.add('Duplicate permission: $code');
      if (!code.contains('.')) errors.add('Invalid permission code format: $code');
    }
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  bool isFeatureEnabled({required String flagKey, required Map<String, bool> flags, bool defaultValue = false}) =>
      flags[flagKey] ?? defaultValue;

  LicenseValidation validateLicense({
    required LicenseStatus status,
    required DateTime? expiresAt,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now().toUtc();
    if (status == LicenseStatus.expired || status == LicenseStatus.suspended) {
      return const LicenseValidation(isValid: false, daysRemaining: 0, reason: 'License is not active');
    }
    if (expiresAt == null) {
      return const LicenseValidation(isValid: true, daysRemaining: 365);
    }
    final days = expiresAt.difference(current).inDays;
    if (days < 0) {
      return const LicenseValidation(isValid: false, daysRemaining: 0, reason: 'License has expired');
    }
    return LicenseValidation(isValid: true, daysRemaining: days);
  }

  ValidationResult validateConfig(Map<String, dynamic> config, {required List<String> requiredKeys}) {
    final errors = <String>[];
    for (final key in requiredKeys) {
      final value = config[key];
      if (value == null || (value is String && value.trim().isEmpty)) {
        errors.add('Missing required config key: $key');
      }
    }
    return ValidationResult(isValid: errors.isEmpty, errors: errors);
  }

  HealthAssessment assessHealth({
    required int openErrors,
    required int pendingSyncItems,
    required double storageUtilizationPercent,
    required bool maintenanceActive,
  }) {
    final issues = <String>[];
    var score = 100.0;
    if (openErrors > 0) {
      issues.add('$openErrors unresolved errors');
      score -= (openErrors * 5).clamp(0, 30).toDouble();
    }
    if (pendingSyncItems > 50) {
      issues.add('$pendingSyncItems pending sync items');
      score -= 15;
    }
    if (storageUtilizationPercent > 90) {
      issues.add('Storage utilization above 90%');
      score -= 20;
    }
    if (maintenanceActive) {
      issues.add('Maintenance mode is active');
      score -= 25;
    }
    score = score.clamp(0, 100);
    final status = score >= 80
        ? HealthStatus.healthy
        : score >= 50
            ? HealthStatus.degraded
            : HealthStatus.critical;
    return HealthAssessment(status: status, score: score, issues: issues);
  }

  UsageSummary calculateUsage({
    required int activeUsers,
    required int licensedUsers,
    required double storageUsedMb,
    required double storageLimitMb,
    required int apiCallsToday,
    required int apiLimitDaily,
  }) {
    final userUtil = licensedUsers > 0 ? (activeUsers / licensedUsers) * 100 : 0.0;
    final storageUtil = storageLimitMb > 0 ? (storageUsedMb / storageLimitMb) * 100 : 0.0;
    final apiUtil = apiLimitDaily > 0 ? (apiCallsToday / apiLimitDaily) * 100 : 0.0;
    final utilization = [userUtil, storageUtil, apiUtil].reduce((a, b) => a > b ? a : b);
    return UsageSummary(
      activeUsers: activeUsers,
      storageUsedMb: storageUsedMb,
      apiCallsToday: apiCallsToday,
      utilizationPercent: double.parse(utilization.toStringAsFixed(2)),
    );
  }

  bool canTransitionOrgUnit(OrgUnitStatus from, OrgUnitStatus to) {
    const allowed = {
      OrgUnitStatus.active: {OrgUnitStatus.inactive, OrgUnitStatus.archived},
      OrgUnitStatus.inactive: {OrgUnitStatus.active, OrgUnitStatus.archived},
      OrgUnitStatus.archived: <OrgUnitStatus>{},
    };
    return allowed[from]?.contains(to) ?? false;
  }

  double calculateStorageQuotaPercent({required double usedMb, required double limitMb}) {
    if (limitMb <= 0) return 0;
    return double.parse(((usedMb / limitMb) * 100).clamp(0, 100).toStringAsFixed(2));
  }
}
