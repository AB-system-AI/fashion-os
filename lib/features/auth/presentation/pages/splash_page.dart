import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/enterprise/app_version_checker.dart';
import 'package:fashion_pos_enterprise/core/enterprise/crash_reporting_service.dart';
import 'package:fashion_pos_enterprise/core/enterprise/remote_config_service.dart';
import 'package:fashion_pos_enterprise/core/local_database/local_database.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/loading/app_loading_indicator.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_state.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/auth/routing/auth_route_paths.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    await CrashReportingService.initialize();
    await LocalDatabase.instance;
    await ref.read(remoteConfigServiceProvider).fetch();

    final versionCheck = await ref.read(appVersionCheckerProvider).check();
    if (versionCheck.forceUpdate && mounted) {
      _showForceUpdateDialog(versionCheck.minimumVersion);
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final auth = ref.read(authControllerProvider);
    final controller = ref.read(authControllerProvider.notifier);

    if (auth.status == AuthStatus.maintenance) {
      context.go(AuthRoutePaths.maintenance);
      return;
    }

    if (!controller.hasSeenOnboarding) {
      context.go(AuthRoutePaths.onboarding);
      return;
    }

    if (auth.status == AuthStatus.authenticated) {
      context.go(AuthRoutePaths.home);
    } else if (auth.status == AuthStatus.emailUnverified) {
      context.go(AuthRoutePaths.verifyEmail);
    } else {
      context.go(AuthRoutePaths.welcome);
    }
  }

  void _showForceUpdateDialog(String? minVersion) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Required'),
        content: Text('Please update to version $minVersion or later.'),
        actions: [
          FilledButton(onPressed: () {}, child: const Text('Update')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppLoadingIndicator(message: 'Fashion POS Enterprise'),
    );
  }
}
