class OrganizationInput {
  const OrganizationInput({required this.name, this.code, this.parentId});

  final String name;
  final String? code;
  final String? parentId;
}

class TenantValidationInput {
  const TenantValidationInput({
    required this.tenantId,
    required this.currentUsers,
    required this.maxUsers,
    required this.usedStorageMb,
    required this.maxStorageMb,
  });

  final String tenantId;
  final int currentUsers;
  final int maxUsers;
  final double usedStorageMb;
  final double maxStorageMb;
}

class RoleAssignmentInput {
  const RoleAssignmentInput({required this.roleId, required this.permissionCodes});

  final String roleId;
  final List<String> permissionCodes;
}

class AdminDashboardMetrics {
  const AdminDashboardMetrics({
    required this.companies,
    required this.activeUsers,
    required this.pendingInvites,
    required this.healthScore,
    required this.licenseDaysRemaining,
  });

  final int companies;
  final int activeUsers;
  final int pendingInvites;
  final double healthScore;
  final int licenseDaysRemaining;
}

class BrandingInput {
  const BrandingInput({this.logoUrl, this.primaryColor, this.accentColor, this.companyName});

  final String? logoUrl;
  final String? primaryColor;
  final String? accentColor;
  final String? companyName;
}

class SettingsUpdateInput {
  const SettingsUpdateInput({required this.scope, required this.values});

  final String scope;
  final Map<String, dynamic> values;
}
