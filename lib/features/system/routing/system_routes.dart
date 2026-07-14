import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/features/system/presentation/pages/audit_explorer_page.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/pages/diagnostics_page.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/pages/environment_settings_page.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/pages/error_logs_page.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/pages/feature_flags_page.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/pages/health_monitor_page.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/pages/maintenance_mode_page.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/pages/permission_manager_page.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/pages/release_notes_page.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/pages/role_manager_page.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/pages/security_center_page.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/pages/sync_monitor_page.dart';
import 'package:fashion_pos_enterprise/features/system/presentation/pages/system_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/system/routing/system_route_paths.dart';

List<RouteBase> buildSystemRoutes() {
  return [
    GoRoute(
      path: SystemRoutePaths.dashboard,
      name: SystemRouteNames.dashboard,
      builder: (_, __) => const SystemDashboardPage(),
      routes: [
        GoRoute(path: 'feature-flags', name: SystemRouteNames.featureFlags, builder: (_, __) => const FeatureFlagsPage()),
        GoRoute(path: 'audit', name: SystemRouteNames.auditExplorer, builder: (_, __) => const AuditExplorerPage()),
        GoRoute(path: 'permissions', name: SystemRouteNames.permissionManager, builder: (_, __) => const PermissionManagerPage()),
        GoRoute(path: 'roles', name: SystemRouteNames.roleManager, builder: (_, __) => const RoleManagerPage()),
        GoRoute(path: 'health', name: SystemRouteNames.healthMonitor, builder: (_, __) => const HealthMonitorPage()),
        GoRoute(path: 'sync', name: SystemRouteNames.syncMonitor, builder: (_, __) => const SyncMonitorPage()),
        GoRoute(path: 'errors', name: SystemRouteNames.errorLogs, builder: (_, __) => const ErrorLogsPage()),
        GoRoute(path: 'security', name: SystemRouteNames.securityCenter, builder: (_, __) => const SecurityCenterPage()),
        GoRoute(path: 'maintenance', name: SystemRouteNames.maintenanceMode, builder: (_, __) => const MaintenanceModePage()),
        GoRoute(path: 'environment', name: SystemRouteNames.environmentSettings, builder: (_, __) => const EnvironmentSettingsPage()),
        GoRoute(path: 'diagnostics', name: SystemRouteNames.diagnostics, builder: (_, __) => const DiagnosticsPage()),
        GoRoute(path: 'release-notes', name: SystemRouteNames.releaseNotes, builder: (_, __) => const ReleaseNotesPage()),
      ],
    ),
  ];
}
