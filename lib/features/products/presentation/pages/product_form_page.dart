import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_text_field.dart';
import 'package:fashion_pos_enterprise/design_system/components/catalog_inputs.dart';
import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';
import 'package:fashion_pos_enterprise/features/products/domain/enums/product_enums.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/widgets/product_image_gallery_section.dart';

/// Create / edit product form — delegates to ProductCatalogService.
class ProductFormPage extends ConsumerStatefulWidget {
  const ProductFormPage({this.productId, super.key});

  final String? productId;

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _name = TextEditingController();
  final _sku = TextEditingController();
  final _barcode = TextEditingController();
  final _retail = TextEditingController();
  final _cost = TextEditingController();
  final _description = TextEditingController();
  bool _loading = false;
  String? _error;
  Product? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      Future.microtask(_load);
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final user = ref.read(authControllerProvider).user;
    final result = await ref.read(productCatalogServiceProvider).getById(widget.productId!, user: user);
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _loading = false;
        _error = result.failureOrNull?.message;
      });
      return;
    }
    final p = result.dataOrNull!;
    _existing = p;
    _name.text = p.name;
    _sku.text = p.sku;
    _barcode.text = p.barcode ?? '';
    _retail.text = p.retailPrice.toString();
    _cost.text = p.cost.toString();
    _description.text = p.description ?? '';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final now = DateTime.now().toUtc();
    final draft = Product(
      id: _existing?.id ?? '',
      tenantId: user.tenantId ?? '',
      name: _name.text.trim(),
      sku: _sku.text.trim(),
      barcode: _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      retailPrice: double.tryParse(_retail.text) ?? 0,
      cost: double.tryParse(_cost.text) ?? 0,
      status: _existing?.status ?? ProductStatus.draft,
      version: _existing?.version ?? 1,
      createdAt: _existing?.createdAt ?? now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    final catalog = ref.read(productCatalogServiceProvider);
    final result = _existing == null
        ? await catalog.createProduct(user: user, draft: draft)
        : await catalog.updateProduct(user: user, product: draft, previous: _existing);

    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _loading = false;
        _error = result.failureOrNull?.message;
      });
      return;
    }
    context.pop();
  }

  @override
  void dispose() {
    _name.dispose();
    _sku.dispose();
    _barcode.dispose();
    _retail.dispose();
    _cost.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.productId != null;
    final canSave = ref.watch(
      permissionCheckProvider(isEdit ? ProductPermissions.update : ProductPermissions.create),
    );

    return AppScaffold(
      appBar: AppAppBar(title: Text(isEdit ? 'Edit Product' : 'New Product')),
      body: _loading && _existing == null && isEdit
          ? const AppStateView(isLoading: true, isEmpty: false, error: null, child: SizedBox())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null) ...[
                    Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    const Gap(AppSpacing.md),
                  ],
                  AppTextField(label: 'Product Name', controller: _name),
                  const Gap(AppSpacing.md),
                  AppBarcodeField(controller: _sku, label: 'SKU'),
                  const Gap(AppSpacing.md),
                  AppBarcodeField(controller: _barcode, label: 'Barcode'),
                  const Gap(AppSpacing.md),
                  AppCurrencyField(controller: _retail, label: 'Retail Price'),
                  const Gap(AppSpacing.md),
                  AppCurrencyField(controller: _cost, label: 'Cost'),
                  const Gap(AppSpacing.md),
                  AppTextField(label: 'Description', controller: _description, maxLines: 4),
                  if (isEdit && widget.productId != null) ...[
                    const Gap(AppSpacing.xl),
                    ProductImageGallerySection(productId: widget.productId!),
                  ],
                  const Gap(AppSpacing.xl),
                  if (canSave)
                    SemanticButton(
                      label: 'Save Product',
                      isLoading: _loading,
                      isExpanded: true,
                      onPressed: _save,
                    ),
                ],
              ),
            ),
    );
  }
}
