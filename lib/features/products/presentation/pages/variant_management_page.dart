import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_text_field.dart';
import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/sheets/app_bottom_sheets.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/catalog/variant_matrix_widget.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product_variant.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/variant_matrix_generator.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';

class VariantManagementPage extends ConsumerStatefulWidget {
  const VariantManagementPage({required this.productId, super.key});

  final String productId;

  @override
  ConsumerState<VariantManagementPage> createState() => _VariantManagementPageState();
}

class _VariantManagementPageState extends ConsumerState<VariantManagementPage> {
  Product? _product;
  List<ProductVariant> _variants = [];
  bool _loading = true;
  String? _error;

  final _colors = TextEditingController();
  final _sizes = TextEditingController();
  final _materials = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    final result = await ref.read(productCatalogServiceProvider).getById(widget.productId, user: user);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result.isFailure) {
        _error = result.failureOrNull?.message;
      } else {
        _product = result.dataOrNull;
        _variants = List.of(_product!.variants);
      }
    });
  }

  Future<void> _generateMatrix() async {
    final input = VariantMatrixInput(
      colors: _split(_colors.text),
      sizes: _split(_sizes.text),
      materials: _split(_materials.text),
      skuPrefix: _product?.sku ?? 'VAR',
      baseRetailPrice: _product?.retailPrice ?? 0,
      baseCost: _product?.cost ?? 0,
    );
    setState(() => _variants = ref.read(productCatalogServiceProvider).generateVariantMatrix(input));
  }

  List<String> _split(String value) =>
      value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  Future<void> _save() async {
    final user = ref.read(authControllerProvider).user;
    final product = _product;
    if (user == null || product == null) return;
    setState(() => _loading = true);
    final result = await ref.read(productCatalogServiceProvider).updateVariants(
          user: user,
          product: product,
          variants: _variants,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isFailure) {
      setState(() => _error = result.failureOrNull?.message);
      return;
    }
    context.pop();
  }

  @override
  void dispose() {
    _colors.dispose();
    _sizes.dispose();
    _materials.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canManage = ref.watch(permissionCheckProvider(ProductPermissions.variantManage));
    return AppScaffold(
      appBar: const AppAppBar(title: Text('Variant Management')),
      body: AppStateView(
        isLoading: _loading && _product == null,
        error: _error,
        isEmpty: false,
        child: _product == null
            ? const SizedBox()
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text('Matrix Generator', style: Theme.of(context).textTheme.titleMedium),
                  const Gap(AppSpacing.sm),
                  AppTextField(label: 'Colors (comma separated)', controller: _colors, hint: 'Black, White, Blue'),
                  const Gap(AppSpacing.sm),
                  AppTextField(label: 'Sizes', controller: _sizes, hint: 'S, M, L, XL'),
                  const Gap(AppSpacing.sm),
                  AppTextField(label: 'Materials', controller: _materials),
                  const Gap(AppSpacing.md),
                  SemanticButton(label: 'Generate Combinations', type: SemanticButtonType.secondary, onPressed: _generateMatrix),
                  const Gap(AppSpacing.xl),
                  VariantMatrixWidget(
                    variants: _variants,
                    onChanged: (v) => setState(() => _variants = v),
                  ),
                  const Gap(AppSpacing.xl),
                  if (canManage)
                    SemanticButton(label: 'Save Variants', isLoading: _loading, isExpanded: true, onPressed: _save),
                ],
              ),
      ),
    );
  }
}
