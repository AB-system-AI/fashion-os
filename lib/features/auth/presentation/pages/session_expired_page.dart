import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/extensions/context_extensions.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_button.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/error_state_widget.dart';
import 'package:fashion_pos_enterprise/features/auth/routing/auth_route_paths.dart';

class SessionExpiredPage extends StatelessWidget {
  const SessionExpiredPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ErrorStateWidget(message: context.l10n.sessionExpiredMessage),
            AppButton(
              label: context.l10n.login,
              onPressed: () => context.go(AuthRoutePaths.login),
            ),
          ],
        ),
      ),
    );
  }
}
