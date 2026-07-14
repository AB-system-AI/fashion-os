import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/features/automation/presentation/pages/ai_assistant_page.dart';
import 'package:fashion_pos_enterprise/features/automation/presentation/pages/approval_workflows_page.dart';
import 'package:fashion_pos_enterprise/features/automation/presentation/pages/automation_dashboard_page.dart';
import 'package:fashion_pos_enterprise/features/automation/presentation/pages/automation_logs_page.dart';
import 'package:fashion_pos_enterprise/features/automation/presentation/pages/document_templates_page.dart';
import 'package:fashion_pos_enterprise/features/automation/presentation/pages/rule_designer_page.dart';
import 'package:fashion_pos_enterprise/features/automation/presentation/pages/scheduled_jobs_page.dart';
import 'package:fashion_pos_enterprise/features/automation/presentation/pages/workflow_list_page.dart';
import 'package:fashion_pos_enterprise/features/automation/routing/automation_route_paths.dart';

List<RouteBase> buildAutomationRoutes() {
  return [
    GoRoute(
      path: AutomationRoutePaths.dashboard,
      name: AutomationRouteNames.dashboard,
      builder: (_, __) => const AutomationDashboardPage(),
      routes: [
        GoRoute(path: 'workflows', name: AutomationRouteNames.workflows, builder: (_, __) => const WorkflowListPage()),
        GoRoute(path: 'rules', name: AutomationRouteNames.rules, builder: (_, __) => const RuleDesignerPage()),
        GoRoute(path: 'scheduled-jobs', name: AutomationRouteNames.scheduledJobs, builder: (_, __) => const ScheduledJobsPage()),
        GoRoute(path: 'logs', name: AutomationRouteNames.logs, builder: (_, __) => const AutomationLogsPage()),
        GoRoute(path: 'approvals', name: AutomationRouteNames.approvals, builder: (_, __) => const ApprovalWorkflowsPage()),
        GoRoute(path: 'ai-assistant', name: AutomationRouteNames.aiAssistant, builder: (_, __) => const AiAssistantPage()),
        GoRoute(path: 'templates', name: AutomationRouteNames.templates, builder: (_, __) => const DocumentTemplatesPage()),
      ],
    ),
  ];
}
