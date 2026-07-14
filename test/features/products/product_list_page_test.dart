import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_state.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/pages/product_list_page.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_list_controller.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_list_state.dart';

void main() {
  testWidgets('ProductListPage shows search and empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authControllerProvider.overrideWith(_FakeAuthController.new),
          permissionCheckProvider.overrideWith((ref, permission) => true),
          productListControllerProvider.overrideWith(_FakeProductListController.new),
        ],
        child: const MaterialApp(home: ProductListPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Products'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('No products yet'), findsOneWidget);
  });
}

class _FakeAuthController extends AuthController {
  @override
  AuthState build() => AuthState(
        status: AuthStatus.authenticated,
        user: const AuthUser(
          userId: 'u1',
          employeeId: 'e1',
          email: 'a@b.com',
          emailVerified: true,
          tenantId: 't1',
          permissions: {'product.read', 'product.create'},
        ),
      );
}

class _FakeProductListController extends ProductListController {
  @override
  ProductListState build() => const ProductListState(isLoading: false);
}
