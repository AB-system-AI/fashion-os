import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';

class _AdminAreaPage extends ConsumerWidget {
  const _AdminAreaPage({required this.title, required this.permission});

  final String title;
  final String permission;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = ref.watch(permissionCheckProvider(permission));
    if (!canView) {
      return AppScaffold(body: PermissionDeniedWidget(permission: permission));
    }
    return AppScaffold(
      appBar: AppAppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Center(child: Text('$title — enterprise administration area')),
      ),
    );
  }
}

class OrganizationsPage extends _AdminAreaPage {
  const OrganizationsPage({super.key}) : super(title: 'Organizations', permission: EnterpriseAdminPermissions.view);
}

class CompaniesPage extends _AdminAreaPage {
  const CompaniesPage({super.key}) : super(title: 'Companies', permission: OrganizationPermissions.manage);
}

class BranchesPage extends _AdminAreaPage {
  const BranchesPage({super.key}) : super(title: 'Branches', permission: OrganizationPermissions.manage);
}

class StoresPage extends _AdminAreaPage {
  const StoresPage({super.key}) : super(title: 'Stores', permission: OrganizationPermissions.manage);
}

class DepartmentsPage extends _AdminAreaPage {
  const DepartmentsPage({super.key}) : super(title: 'Departments', permission: OrganizationPermissions.manage);
}

class TeamsPage extends _AdminAreaPage {
  const TeamsPage({super.key}) : super(title: 'Teams', permission: OrganizationPermissions.manage);
}

class UsersPage extends _AdminAreaPage {
  const UsersPage({super.key}) : super(title: 'Users', permission: UserAdminPermissions.admin);
}

class RolesPage extends _AdminAreaPage {
  const RolesPage({super.key}) : super(title: 'Roles', permission: RoleAdminPermissions.admin);
}

class PermissionsPage extends _AdminAreaPage {
  const PermissionsPage({super.key}) : super(title: 'Permissions', permission: RoleAdminPermissions.admin);
}

class TenantSettingsPage extends _AdminAreaPage {
  const TenantSettingsPage({super.key}) : super(title: 'Tenant Settings', permission: TenantSettingsPermissions.settings);
}

class BrandingPage extends _AdminAreaPage {
  const BrandingPage({super.key}) : super(title: 'Branding', permission: TenantSettingsPermissions.settings);
}

class LocalizationPage extends _AdminAreaPage {
  const LocalizationPage({super.key}) : super(title: 'Localization', permission: TenantSettingsPermissions.settings);
}

class CurrencySettingsPage extends _AdminAreaPage {
  const CurrencySettingsPage({super.key}) : super(title: 'Currency Settings', permission: TenantSettingsPermissions.settings);
}

class FiscalSettingsPage extends _AdminAreaPage {
  const FiscalSettingsPage({super.key}) : super(title: 'Fiscal Settings', permission: TenantSettingsPermissions.settings);
}

class NumberingSettingsPage extends _AdminAreaPage {
  const NumberingSettingsPage({super.key}) : super(title: 'Numbering Settings', permission: TenantSettingsPermissions.settings);
}

class FeatureFlagsPage extends _AdminAreaPage {
  const FeatureFlagsPage({super.key}) : super(title: 'Feature Flags', permission: EnterpriseAdminPermissions.manage);
}

class LicensePage extends _AdminAreaPage {
  const LicensePage({super.key}) : super(title: 'License', permission: EnterpriseAdminPermissions.manage);
}

class UsageDashboardPage extends _AdminAreaPage {
  const UsageDashboardPage({super.key}) : super(title: 'Usage Dashboard', permission: EnterpriseAdminPermissions.view);
}

class StorageDashboardPage extends _AdminAreaPage {
  const StorageDashboardPage({super.key}) : super(title: 'Storage Dashboard', permission: EnterpriseAdminPermissions.view);
}

class ApiUsagePage extends _AdminAreaPage {
  const ApiUsagePage({super.key}) : super(title: 'API Usage', permission: EnterpriseAdminPermissions.view);
}

class HealthDashboardPage extends _AdminAreaPage {
  const HealthDashboardPage({super.key}) : super(title: 'Health Dashboard', permission: EnterpriseAdminPermissions.view);
}

class JobsMonitorPage extends _AdminAreaPage {
  const JobsMonitorPage({super.key}) : super(title: 'Jobs Monitor', permission: EnterpriseAdminPermissions.view);
}

class SyncMonitorPage extends _AdminAreaPage {
  const SyncMonitorPage({super.key}) : super(title: 'Sync Monitor', permission: EnterpriseAdminPermissions.view);
}

class DevicesPage extends _AdminAreaPage {
  const DevicesPage({super.key}) : super(title: 'Devices', permission: EnterpriseAdminPermissions.view);
}

class SessionsPage extends _AdminAreaPage {
  const SessionsPage({super.key}) : super(title: 'Sessions', permission: EnterpriseAdminPermissions.view);
}

class LoginHistoryPage extends _AdminAreaPage {
  const LoginHistoryPage({super.key}) : super(title: 'Login History', permission: EnterpriseAdminPermissions.view);
}

class MaintenancePage extends _AdminAreaPage {
  const MaintenancePage({super.key}) : super(title: 'Maintenance', permission: EnterpriseAdminPermissions.manage);
}

class ReleaseManagerPage extends _AdminAreaPage {
  const ReleaseManagerPage({super.key}) : super(title: 'Release Manager', permission: EnterpriseAdminPermissions.manage);
}

class MigrationManagerPage extends _AdminAreaPage {
  const MigrationManagerPage({super.key}) : super(title: 'Migration Manager', permission: EnterpriseAdminPermissions.manage);
}

class DiagnosticsPage extends _AdminAreaPage {
  const DiagnosticsPage({super.key}) : super(title: 'Diagnostics', permission: EnterpriseAdminPermissions.view);
}

class DeveloperToolsPage extends _AdminAreaPage {
  const DeveloperToolsPage({super.key}) : super(title: 'Developer Tools', permission: EnterpriseAdminPermissions.manage);
}

class AdminReportsPage extends _AdminAreaPage {
  const AdminReportsPage({super.key}) : super(title: 'Admin Reports', permission: EnterpriseAdminPermissions.view);
}
