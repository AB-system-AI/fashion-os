import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/analytics/presentation/providers/analytics_providers.dart';

final analyticsModuleInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final sync = ref.read(syncCoordinatorProvider);
    sync.registerProcessor(ref.read(reportDefinitionSyncProcessorProvider));
    sync.registerProcessor(ref.read(reportTemplateSyncProcessorProvider));
    sync.registerProcessor(ref.read(reportExportSyncProcessorProvider));
    sync.registerProcessor(ref.read(reportSnapshotSyncProcessorProvider));
    sync.registerProcessor(ref.read(dashboardLayoutSyncProcessorProvider));
    sync.registerProcessor(ref.read(dashboardWidgetSyncProcessorProvider));
    sync.registerProcessor(ref.read(analyticsSnapshotSyncProcessorProvider));
    sync.registerProcessor(ref.read(kpiSnapshotSyncProcessorProvider));
    sync.registerProcessor(ref.read(scheduledReportSyncProcessorProvider));
    sync.registerProcessor(ref.read(reportExecutionHistorySyncProcessorProvider));
  };
});
