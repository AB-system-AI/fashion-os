import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/workflow/presentation/providers/workflow_providers.dart';

final workflowModuleInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final sync = ref.read(syncCoordinatorProvider);
    sync.registerProcessor(ref.read(wfDefinitionSyncProcessorProvider));
    sync.registerProcessor(ref.read(wfInstanceSyncProcessorProvider));
    sync.registerProcessor(ref.read(approvalTemplateSyncProcessorProvider));
    sync.registerProcessor(ref.read(approvalMatrixSyncProcessorProvider));
    sync.registerProcessor(ref.read(wfApprovalRequestSyncProcessorProvider));
    sync.registerProcessor(ref.read(wfApprovalHistorySyncProcessorProvider));
    sync.registerProcessor(ref.read(wfApprovalDelegationSyncProcessorProvider));
    sync.registerProcessor(ref.read(wfNotificationSyncProcessorProvider));
    sync.registerProcessor(ref.read(reminderRuleSyncProcessorProvider));
    sync.registerProcessor(ref.read(escalationRuleSyncProcessorProvider));
    sync.registerProcessor(ref.read(wfTemplateSyncProcessorProvider));
    sync.registerProcessor(ref.read(wfTemplateVersionSyncProcessorProvider));
    sync.registerProcessor(ref.read(wfCategorySyncProcessorProvider));
    sync.registerProcessor(ref.read(wfExecutionSyncProcessorProvider));
    sync.registerProcessor(ref.read(wfExecutionLogSyncProcessorProvider));
    sync.registerProcessor(ref.read(wfStatisticsSyncProcessorProvider));
    sync.registerProcessor(ref.read(notificationQueueSyncProcessorProvider));
    sync.registerProcessor(ref.read(notificationDeadLetterSyncProcessorProvider));
    sync.registerProcessor(ref.read(notificationPreferenceSyncProcessorProvider));
    sync.registerProcessor(ref.read(schedulerJobSyncProcessorProvider));
    sync.registerProcessor(ref.read(schedulerExecutionLogSyncProcessorProvider));
  };
});
