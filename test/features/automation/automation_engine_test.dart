import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/business/engines/automation/automation_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/automation_rule.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/execution.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/entities/workflow.dart';
import 'package:fashion_pos_enterprise/features/automation/domain/enums/automation_enums.dart';

AutomationRule _rule({String field = 'amount', String op = 'greaterThan', String value = '100'}) {
  final now = DateTime.utc(2025, 1, 1);
  return AutomationRule(
    id: 'rule-1',
    tenantId: 'tenant-1',
    name: 'High value',
    status: RuleStatus.active,
    conditionField: field,
    conditionOperator: op,
    conditionValue: value,
    actionType: 'notify',
    version: 1,
    createdAt: now,
    updatedAt: now,
    syncStatus: LocalSyncStatus.synced,
    isDirty: false,
  );
}

void main() {
  late AutomationEngine engine;

  setUp(() => engine = AutomationEngine());

  test('evaluateRules matches context above threshold', () {
    final plans = engine.evaluateRules(
      rules: [_rule()],
      context: {'amount': 500},
    );
    expect(plans.single.matched, isTrue);
  });

  test('evaluateRules does not match below threshold', () {
    final plans = engine.evaluateRules(
      rules: [_rule()],
      context: {'amount': 50},
    );
    expect(plans.single.matched, isFalse);
  });

  test('planWorkflow rejects inactive workflow', () {
    final now = DateTime.utc(2025, 1, 1);
    final workflow = AutomationWorkflow(
      id: 'wf-1',
      tenantId: 't1',
      name: 'Test',
      status: WorkflowStatus.draft,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.synced,
      isDirty: false,
    );
    final plan = engine.planWorkflow(workflow: workflow, steps: const []);
    expect(plan.canStart, isFalse);
  });

  test('generateSuggestions recommends activating draft rules', () {
    final now = DateTime.utc(2025, 1, 1);
    final suggestions = engine.generateSuggestions(
      rules: [
        AutomationRule(
          id: 'r1',
          tenantId: 't1',
          name: 'Draft rule',
          status: RuleStatus.draft,
          version: 1,
          createdAt: now,
          updatedAt: now,
          syncStatus: LocalSyncStatus.synced,
          isDirty: false,
        ),
      ],
      workflows: const [],
      recentExecutions: const [],
      jobs: const [],
    );
    expect(suggestions.any((s) => s.type == SuggestionType.rule), isTrue);
  });

  test('summarize computes success rate', () {
    final now = DateTime.utc(2025, 1, 1);
    final summary = engine.summarize(
      executions: [
        AutomationExecution(
          id: 'e1',
          tenantId: 't1',
          status: ExecutionStatus.succeeded,
          version: 1,
          createdAt: now,
          updatedAt: now,
          syncStatus: LocalSyncStatus.synced,
          isDirty: false,
        ),
        AutomationExecution(
          id: 'e2',
          tenantId: 't1',
          status: ExecutionStatus.failed,
          version: 1,
          createdAt: now,
          updatedAt: now,
          syncStatus: LocalSyncStatus.synced,
          isDirty: false,
        ),
      ],
      rules: const [],
      workflows: const [],
      queue: const [],
    );
    expect(summary.successRate, 50);
  });
}
