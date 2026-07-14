import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/workflow/workflow_designer_engine.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/entities/workflow_template.dart';
import 'package:fashion_pos_enterprise/features/workflow/domain/enums/workflow_enums.dart';

void main() {
  late WorkflowDesignerEngine engine;

  setUp(() => engine = WorkflowDesignerEngine());

  WorkflowTemplate template() => WorkflowTemplate(
        id: 'tpl-1',
        tenantId: 'tenant-1',
        name: 'Purchase flow',
        version: 1,
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      );

  WorkflowVersion version({List<WorkflowAction>? steps}) => WorkflowVersion(
        id: 'ver-1',
        tenantId: 'tenant-1',
        templateId: 'tpl-1',
        versionNumber: 1,
        status: WorkflowVersionStatus.draft,
        steps: steps ??
            [
              WorkflowAction(
                id: 's1',
                name: 'Manager',
                order: 0,
                actions: [WorkflowStepAction(actionType: WorkflowActionType.approval)],
              ),
            ],
        version: 1,
        createdAt: DateTime.utc(2025, 1, 1),
        updatedAt: DateTime.utc(2025, 1, 1),
        syncStatus: LocalSyncStatus.synced,
        isDirty: false,
      );

  test('validateTemplate rejects empty steps', () {
    final result = engine.validateTemplate(template(), version(steps: []));
    expect(result.isValid, isFalse);
    expect(result.issues.any((i) => i.code == 'steps_required'), isTrue);
  });

  test('publishVersion promotes valid draft', () {
    final draft = version();
    final published = engine.publishVersion(draft);
    expect(published.status, WorkflowVersionStatus.published);
    expect(published.publishedAt, isNotNull);
  });

  test('simulate produces step trace', () {
    final result = engine.simulate(template: template(), version: version());
    expect(result.steps, isNotEmpty);
    expect(result.wouldComplete, isTrue);
  });

  test('cloneTemplate creates new draft template', () {
    final cloned = engine.cloneTemplate(
      source: template(),
      sourceVersion: version(),
      newId: 'tpl-2',
      newName: 'Purchase flow copy',
    );
    expect(cloned.id, 'tpl-2');
    expect(cloned.status, WorkflowDefinitionStatus.draft);
  });

  test('export and import round-trip', () {
    final bundle = engine.exportBundle(
      template: template(),
      versions: [version()],
      variables: [const WorkflowVariable(key: 'amount', label: 'Amount')],
    );
    final imported = engine.importBundle(bundle.toJson(), 'tenant-2');
    expect(imported.template.tenantId, 'tenant-2');
    expect(imported.versions, hasLength(1));
    expect(imported.variables, hasLength(1));
  });
}
