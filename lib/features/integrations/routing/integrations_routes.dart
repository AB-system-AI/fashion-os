import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/features/integrations/presentation/pages/api_keys_page.dart';
import 'package:fashion_pos_enterprise/features/integrations/presentation/pages/connectors_page.dart';
import 'package:fashion_pos_enterprise/features/integrations/presentation/pages/email_settings_page.dart';
import 'package:fashion_pos_enterprise/features/integrations/presentation/pages/health_status_page.dart';
import 'package:fashion_pos_enterprise/features/integrations/presentation/pages/import_export_hub_page.dart';
import 'package:fashion_pos_enterprise/features/integrations/presentation/pages/integrations_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/integrations/presentation/pages/printer_manager_page.dart';
import 'package:fashion_pos_enterprise/features/integrations/presentation/pages/webhooks_page.dart';
import 'package:fashion_pos_enterprise/features/integrations/routing/integrations_route_paths.dart';

List<RouteBase> buildIntegrationsRoutes() {
  return [
    GoRoute(
      path: IntegrationsRoutePaths.dashboard,
      name: IntegrationsRouteNames.dashboard,
      builder: (_, __) => const IntegrationsDashboardPage(),
      routes: [
        GoRoute(path: 'connectors', name: IntegrationsRouteNames.connectors, builder: (_, __) => const ConnectorsPage()),
        GoRoute(path: 'webhooks', name: IntegrationsRouteNames.webhooks, builder: (_, __) => const WebhooksPage()),
        GoRoute(path: 'api-keys', name: IntegrationsRouteNames.apiKeys, builder: (_, __) => const ApiKeysPage()),
        GoRoute(path: 'email', name: IntegrationsRouteNames.emailSettings, builder: (_, __) => const EmailSettingsPage()),
        GoRoute(path: 'import-export', name: IntegrationsRouteNames.importExportHub, builder: (_, __) => const ImportExportHubPage()),
        GoRoute(path: 'printers', name: IntegrationsRouteNames.printerManager, builder: (_, __) => const PrinterManagerPage()),
        GoRoute(path: 'health', name: IntegrationsRouteNames.healthStatus, builder: (_, __) => const HealthStatusPage()),
      ],
    ),
  ];
}
