import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_state.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/auth/routing/auth_route_paths.dart';
import 'package:fashion_pos_enterprise/features/auth/routing/auth_routes.dart';
import 'package:fashion_pos_enterprise/features/products/routing/product_routes.dart';
import 'package:fashion_pos_enterprise/features/inventory/routing/inventory_routes.dart';
import 'package:fashion_pos_enterprise/features/purchasing/routing/purchasing_routes.dart';
import 'package:fashion_pos_enterprise/features/customers/routing/customer_routes.dart';
import 'package:fashion_pos_enterprise/features/pos/routing/pos_routes.dart';
import 'package:fashion_pos_enterprise/features/accounting/routing/accounting_routes.dart';
import 'package:fashion_pos_enterprise/features/hr/routing/hr_routes.dart';
import 'package:fashion_pos_enterprise/features/manufacturing/routing/manufacturing_routes.dart';
import 'package:fashion_pos_enterprise/features/analytics/routing/analytics_routes.dart';
import 'package:fashion_pos_enterprise/features/sales/routing/sales_routes.dart';
import 'package:fashion_pos_enterprise/features/treasury/routing/treasury_routes.dart';
import 'package:fashion_pos_enterprise/features/system/routing/system_routes.dart';
import 'package:fashion_pos_enterprise/features/automation/routing/automation_routes.dart';
import 'package:fashion_pos_enterprise/features/integrations/routing/integrations_routes.dart';
import 'package:fashion_pos_enterprise/features/assets/routing/assets_routes.dart';
import 'package:fashion_pos_enterprise/features/admin/routing/admin_routes.dart';
import 'package:fashion_pos_enterprise/features/workflow/routing/workflow_routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  ref.onDispose(notifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AuthRoutePaths.splash,
    debugLogDiagnostics: true,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      ...buildAuthRoutes(),
      ...buildProductRoutes(),
      ...buildInventoryRoutes(),
      ...buildPurchasingRoutes(),
      ...buildCustomerRoutes(),
      ...buildPosRoutes(),
      ...buildAccountingRoutes(),
      ...buildHrRoutes(),
      ...buildManufacturingRoutes(),
      ...buildAnalyticsRoutes(),
      ...buildSalesRoutes(),
      ...buildTreasuryRoutes(),
      ...buildIntegrationsRoutes(),
      ...buildAutomationRoutes(),
      ...buildSystemRoutes(),
      ...buildWorkflowRoutes(),
      ...buildAssetsRoutes(),
      ...buildAdminRoutes(),
    ],
    errorBuilder: (context, state) {
      AppLogger.error('Route error: ${state.error}');
      return const Scaffold(body: Center(child: Text('Page not found')));
    },
  );
});

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _subscription = _ref.listen(authControllerProvider, (_, __) {
      notifyListeners();
    });
  }

  final Ref _ref;
  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final auth = _ref.read(authControllerProvider);
    final location = state.matchedLocation;
    final isPublic = authPublicRoutes.contains(location);

    if (auth.isLoading && location != AuthRoutePaths.splash) {
      return AuthRoutePaths.splash;
    }

    return switch (auth.status) {
      AuthStatus.unknown =>
        location == AuthRoutePaths.splash ? null : AuthRoutePaths.splash,
      AuthStatus.maintenance => AuthRoutePaths.maintenance,
      AuthStatus.unauthenticated => isPublic ? null : AuthRoutePaths.welcome,
      AuthStatus.emailUnverified =>
        location == AuthRoutePaths.verifyEmail ? null : AuthRoutePaths.verifyEmail,
      AuthStatus.noAccess =>
        location == AuthRoutePaths.noAccess ? null : AuthRoutePaths.noAccess,
      AuthStatus.sessionExpired =>
        location == AuthRoutePaths.sessionExpired ? null : AuthRoutePaths.sessionExpired,
      AuthStatus.onboardingRequired =>
        location == AuthRoutePaths.onboarding ? null : AuthRoutePaths.onboarding,
      AuthStatus.authenticated =>
        isPublic && location != AuthRoutePaths.home ? AuthRoutePaths.home : null,
    };
  }
}
