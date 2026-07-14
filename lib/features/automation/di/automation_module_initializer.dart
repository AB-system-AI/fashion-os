import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/automation/presentation/providers/automation_providers.dart';

final automationModuleInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final sync = ref.read(syncCoordinatorProvider);
    sync.registerProcessor(ref.read(automationRuleSyncProcessorProvider));
    sync.registerProcessor(ref.read(automationWorkflowSyncProcessorProvider));
    sync.registerProcessor(ref.read(workflowStepSyncProcessorProvider));
    sync.registerProcessor(ref.read(scheduledJobSyncProcessorProvider));
    sync.registerProcessor(ref.read(jobQueueItemSyncProcessorProvider));
    sync.registerProcessor(ref.read(automationExecutionSyncProcessorProvider));
    sync.registerProcessor(ref.read(automationLogSyncProcessorProvider));
    sync.registerProcessor(ref.read(approvalWorkflowSyncProcessorProvider));
    sync.registerProcessor(ref.read(approvalRequestSyncProcessorProvider));
    sync.registerProcessor(ref.read(documentTemplateSyncProcessorProvider));
    sync.registerProcessor(ref.read(automationSettingsSyncProcessorProvider));
  };
});
