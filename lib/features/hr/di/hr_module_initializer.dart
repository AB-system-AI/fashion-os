import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/di/enterprise_providers.dart';
import 'package:fashion_pos_enterprise/features/hr/presentation/providers/hr_providers.dart';

final hrModuleInitializerProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final sync = ref.read(syncCoordinatorProvider);
    sync.registerProcessor(ref.read(employeeSyncProcessorProvider));
    sync.registerProcessor(ref.read(attendanceSyncProcessorProvider));
    sync.registerProcessor(ref.read(payrollSyncProcessorProvider));
    sync.registerProcessor(ref.read(leaveSyncProcessorProvider));
    ref.read(hrIntegrationServiceProvider).register();
  };
});
