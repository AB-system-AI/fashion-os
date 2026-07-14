import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fashion_pos_enterprise/core/enterprise/remote_config_service.dart';
import 'package:fashion_pos_enterprise/core/extensions/context_extensions.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/error_state_widget.dart';

class MaintenancePage extends ConsumerWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(remoteConfigServiceProvider).maintenanceMessage;

    return Scaffold(
      body: Center(
        child: ErrorStateWidget(
          message: message ?? context.l10n.maintenanceMessage,
        ),
      ),
    );
  }
}
