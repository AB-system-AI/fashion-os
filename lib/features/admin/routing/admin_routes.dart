import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/admin_reports_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/api_usage_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/audit_explorer_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/branches_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/branding_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/companies_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/currency_settings_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/departments_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/developer_tools_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/devices_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/diagnostics_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/feature_flags_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/fiscal_settings_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/health_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/jobs_monitor_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/license_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/localization_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/login_history_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/maintenance_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/migration_manager_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/numbering_settings_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/organizations_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/permissions_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/release_manager_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/roles_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/sessions_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/storage_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/stores_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/sync_monitor_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/teams_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/tenant_settings_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/usage_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/admin/presentation/pages/users_page.dart';
import 'package:fashion_pos_enterprise/features/admin/routing/admin_route_paths.dart';

List<RouteBase> buildAdminRoutes() {
  return [
    GoRoute(
      path: AdminRoutePaths.dashboard,
      name: AdminRouteNames.dashboard,
      builder: (_, __) => const AdminDashboardPage(),
      routes: [
        GoRoute(path: 'organizations', name: AdminRouteNames.organizations, builder: (_, __) => const OrganizationsPage()),
        GoRoute(path: 'companies', name: AdminRouteNames.companies, builder: (_, __) => const CompaniesPage()),
        GoRoute(path: 'branches', name: AdminRouteNames.branches, builder: (_, __) => const BranchesPage()),
        GoRoute(path: 'stores', name: AdminRouteNames.stores, builder: (_, __) => const StoresPage()),
        GoRoute(path: 'departments', name: AdminRouteNames.departments, builder: (_, __) => const DepartmentsPage()),
        GoRoute(path: 'teams', name: AdminRouteNames.teams, builder: (_, __) => const TeamsPage()),
        GoRoute(path: 'users', name: AdminRouteNames.users, builder: (_, __) => const UsersPage()),
        GoRoute(path: 'roles', name: AdminRouteNames.roles, builder: (_, __) => const RolesPage()),
        GoRoute(path: 'permissions', name: AdminRouteNames.permissions, builder: (_, __) => const PermissionsPage()),
        GoRoute(path: 'tenant-settings', name: AdminRouteNames.tenantSettings, builder: (_, __) => const TenantSettingsPage()),
        GoRoute(path: 'branding', name: AdminRouteNames.branding, builder: (_, __) => const BrandingPage()),
        GoRoute(path: 'localization', name: AdminRouteNames.localization, builder: (_, __) => const LocalizationPage()),
        GoRoute(path: 'currency-settings', name: AdminRouteNames.currencySettings, builder: (_, __) => const CurrencySettingsPage()),
        GoRoute(path: 'fiscal-settings', name: AdminRouteNames.fiscalSettings, builder: (_, __) => const FiscalSettingsPage()),
        GoRoute(path: 'numbering-settings', name: AdminRouteNames.numberingSettings, builder: (_, __) => const NumberingSettingsPage()),
        GoRoute(path: 'feature-flags', name: AdminRouteNames.featureFlags, builder: (_, __) => const FeatureFlagsPage()),
        GoRoute(path: 'license', name: AdminRouteNames.license, builder: (_, __) => const LicensePage()),
        GoRoute(path: 'usage', name: AdminRouteNames.usageDashboard, builder: (_, __) => const UsageDashboardPage()),
        GoRoute(path: 'storage', name: AdminRouteNames.storageDashboard, builder: (_, __) => const StorageDashboardPage()),
        GoRoute(path: 'api-usage', name: AdminRouteNames.apiUsage, builder: (_, __) => const ApiUsagePage()),
        GoRoute(path: 'health', name: AdminRouteNames.healthDashboard, builder: (_, __) => const HealthDashboardPage()),
        GoRoute(path: 'audit', name: AdminRouteNames.auditExplorer, builder: (_, __) => const AdminAuditExplorerPage()),
        GoRoute(path: 'jobs', name: AdminRouteNames.jobsMonitor, builder: (_, __) => const JobsMonitorPage()),
        GoRoute(path: 'sync', name: AdminRouteNames.syncMonitor, builder: (_, __) => const SyncMonitorPage()),
        GoRoute(path: 'devices', name: AdminRouteNames.devices, builder: (_, __) => const DevicesPage()),
        GoRoute(path: 'sessions', name: AdminRouteNames.sessions, builder: (_, __) => const SessionsPage()),
        GoRoute(path: 'login-history', name: AdminRouteNames.loginHistory, builder: (_, __) => const LoginHistoryPage()),
        GoRoute(path: 'maintenance', name: AdminRouteNames.maintenance, builder: (_, __) => const MaintenancePage()),
        GoRoute(path: 'releases', name: AdminRouteNames.releaseManager, builder: (_, __) => const ReleaseManagerPage()),
        GoRoute(path: 'migrations', name: AdminRouteNames.migrationManager, builder: (_, __) => const MigrationManagerPage()),
        GoRoute(path: 'diagnostics', name: AdminRouteNames.diagnostics, builder: (_, __) => const DiagnosticsPage()),
        GoRoute(path: 'developer-tools', name: AdminRouteNames.developerTools, builder: (_, __) => const DeveloperToolsPage()),
        GoRoute(path: 'reports', name: AdminRouteNames.reports, builder: (_, __) => const AdminReportsPage()),
      ],
    ),
  ];
}
