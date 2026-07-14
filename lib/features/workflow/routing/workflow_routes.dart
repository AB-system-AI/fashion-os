import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/features/workflow/presentation/pages/approval_analytics_page.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/pages/approval_templates_page.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/pages/approvals_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/pages/escalation_rules_page.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/pages/notification_center_page.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/pages/notification_preferences_page.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/pages/scheduler_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/pages/workflow_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/pages/workflow_designer_page.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/pages/workflow_reports_page.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/pages/workflow_simulator_page.dart';
import 'package:fashion_pos_enterprise/features/workflow/routing/workflow_route_paths.dart';

List<RouteBase> buildWorkflowRoutes() {
  return [
    GoRoute(
      path: WorkflowRoutePaths.dashboard,
      name: WorkflowRouteNames.dashboard,
      builder: (_, __) => const WorkflowDashboardPage(),
      routes: [
        GoRoute(
          path: 'approval-templates',
          name: WorkflowRouteNames.approvalTemplates,
          builder: (_, __) => const ApprovalTemplatesPage(),
        ),
        GoRoute(
          path: 'escalation-rules',
          name: WorkflowRouteNames.escalationRules,
          builder: (_, __) => const EscalationRulesPage(),
        ),
        GoRoute(
          path: 'designer',
          name: WorkflowRouteNames.designer,
          builder: (_, __) => const WorkflowDesignerPage(),
        ),
        GoRoute(
          path: 'simulator',
          name: WorkflowRouteNames.simulator,
          builder: (_, __) => const WorkflowSimulatorPage(),
        ),
        GoRoute(
          path: 'reports',
          name: WorkflowRouteNames.reports,
          builder: (_, __) => const WorkflowReportsPage(),
        ),
        GoRoute(
          path: 'scheduler',
          name: WorkflowRouteNames.scheduler,
          builder: (_, __) => const SchedulerDashboardPage(),
        ),
        GoRoute(
          path: 'notification-preferences',
          name: WorkflowRouteNames.notificationPreferences,
          builder: (_, __) => const NotificationPreferencesPage(),
        ),
        GoRoute(
          path: 'approval-analytics',
          name: WorkflowRouteNames.approvalAnalytics,
          builder: (_, __) => const ApprovalAnalyticsPage(),
        ),
      ],
    ),
    GoRoute(
      path: WorkflowRoutePaths.approvals,
      name: WorkflowRouteNames.approvals,
      builder: (_, __) => const ApprovalsDashboardPage(),
    ),
    GoRoute(
      path: WorkflowRoutePaths.notifications,
      name: WorkflowRouteNames.notifications,
      builder: (_, __) => const NotificationCenterPage(),
    ),
  ];
}
