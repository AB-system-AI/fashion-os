import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/features/products/presentation/pages/barcode_label_page.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/pages/brand_form_page.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/pages/brand_list_page.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/pages/category_form_page.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/pages/category_list_page.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/pages/product_detail_page.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/pages/product_form_page.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/pages/product_import_page.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/pages/product_list_page.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/pages/variant_management_page.dart';
import 'package:fashion_pos_enterprise/features/products/routing/product_route_paths.dart';

List<RouteBase> buildProductRoutes() {
  return [
    GoRoute(
      path: ProductRoutePaths.list,
      name: ProductRouteNames.list,
      builder: (context, state) => const ProductListPage(),
      routes: [
        GoRoute(
          path: 'new',
          name: ProductRouteNames.create,
          builder: (context, state) => const ProductFormPage(),
        ),
        GoRoute(
          path: 'categories',
          name: ProductRouteNames.categories,
          builder: (context, state) => const CategoryListPage(),
          routes: [
            GoRoute(
              path: 'new',
              name: ProductRouteNames.categoryCreate,
              builder: (context, state) => CategoryFormPage(parentId: state.uri.queryParameters['parentId']),
            ),
            GoRoute(
              path: ':id/edit',
              name: ProductRouteNames.categoryEdit,
              builder: (context, state) => CategoryFormPage(categoryId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: 'brands',
          name: ProductRouteNames.brands,
          builder: (context, state) => const BrandListPage(),
          routes: [
            GoRoute(
              path: 'new',
              name: ProductRouteNames.brandCreate,
              builder: (context, state) => const BrandFormPage(),
            ),
            GoRoute(
              path: ':id/edit',
              name: ProductRouteNames.brandEdit,
              builder: (context, state) => BrandFormPage(brandId: state.pathParameters['id']!),
            ),
          ],
        ),
        GoRoute(
          path: 'import',
          name: ProductRouteNames.import,
          builder: (context, state) => const ProductImportPage(),
        ),
        GoRoute(
          path: ':id',
          name: ProductRouteNames.detail,
          builder: (context, state) => ProductDetailPage(productId: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: 'edit',
              name: ProductRouteNames.edit,
              builder: (context, state) => ProductFormPage(productId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'variants',
              name: ProductRouteNames.variants,
              builder: (context, state) => VariantManagementPage(productId: state.pathParameters['id']!),
            ),
            GoRoute(
              path: 'labels',
              name: ProductRouteNames.barcodeLabels,
              builder: (context, state) => BarcodeLabelPage(productId: state.pathParameters['id']!),
            ),
          ],
        ),
      ],
    ),
  ];
}
