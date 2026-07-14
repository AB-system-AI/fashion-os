import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/design_system/components/catalog_cards.dart';
import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/dialogs/app_dialogs.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/catalog/audit_timeline_widget.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/product_inventory_preview_service.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/widgets/product_image_gallery_section.dart';
import 'package:fashion_pos_enterprise/features/products/routing/product_route_paths.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  const ProductDetailPage({required this.productId, super.key});

  final String productId;

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  Product? _product;
  List<AuditEntry> _timeline = [];
  InventoryPreviewSummary? _inventory;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    final catalog = ref.read(productCatalogServiceProvider);
    final result = await catalog.getById(widget.productId, user: user);
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _loading = false;
        _error = result.failureOrNull?.message;
      });
      return;
    }
    final product = result.dataOrNull!;
    final timeline = await catalog.productTimeline(widget.productId);
    setState(() {
      _loading = false;
      _product = product;
      _timeline = timeline;
      _inventory = catalog.inventoryPreview(product);
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final inventory = _inventory;
    return AppScaffold(
      appBar: AppAppBar(
        title: Text(product?.name ?? 'Product'),
        actions: [
          if (product != null) ...[
            SemanticIconButton(
              icon: Icons.qr_code,
              tooltip: 'Regenerate barcode',
              onPressed: () async {
                final user = ref.read(authControllerProvider).user;
                if (user == null) return;
                final result = await ref.read(productCatalogServiceProvider).regenerateBarcode(user: user, product: product);
                if (mounted && result.isSuccess) {
                  showSuccessDialog(context, message: 'Barcode: ${result.dataOrNull}');
                  _load();
                }
              },
            ),
            SemanticIconButton(icon: Icons.edit, tooltip: 'Edit', onPressed: () => context.push(ProductRoutePaths.edit(product.id))),
          ],
        ],
      ),
      body: AppStateView(
        isLoading: _loading,
        error: _error,
        isEmpty: product == null && !_loading && _error == null,
        onRetry: _load,
        child: product == null
            ? const SizedBox()
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  StatisticCard(label: 'Retail Price', value: '\$${product.retailPrice.toStringAsFixed(2)}', icon: Icons.sell_outlined),
                  const Gap(AppSpacing.md),
                  if (inventory != null)
                    SummaryCard(
                      title: 'Inventory Preview',
                      children: [
                        _row('Available', inventory.available.toStringAsFixed(0)),
                        _row('Reserved', inventory.reserved.toStringAsFixed(0)),
                        _row('Incoming', inventory.incoming.toStringAsFixed(0)),
                        _row('Damaged', inventory.damaged.toStringAsFixed(0)),
                        _row('Returned', inventory.returned.toStringAsFixed(0)),
                        _row('Sold Today', inventory.soldToday.toStringAsFixed(0)),
                      ],
                    ),
                  const Gap(AppSpacing.md),
                  SummaryCard(
                    title: 'Details',
                    children: [
                      _row('SKU', product.sku),
                      _row('Barcode', product.barcode ?? '—'),
                      _row('Status', product.status.name),
                      _row('Variants', product.variants.length.toString()),
                      _row('Images', product.imageAssetIds.length.toString()),
                      if (product.description != null) _row('Description', product.description!),
                    ],
                  ),
                  const Gap(AppSpacing.md),
                  ProductImageGallerySection(productId: product.id),
                  const Gap(AppSpacing.md),
                  SemanticButton(label: 'Manage Variants', type: SemanticButtonType.secondary, onPressed: () => context.push(ProductRoutePaths.variants(product.id))),
                  const Gap(AppSpacing.sm),
                  SemanticButton(label: 'Barcode Labels', type: SemanticButtonType.secondary, onPressed: () => context.push(ProductRoutePaths.barcodeLabels(product.id))),
                  const Gap(AppSpacing.lg),
                  Text('Activity Timeline', style: Theme.of(context).textTheme.titleMedium),
                  const Gap(AppSpacing.sm),
                  AuditTimelineWidget(entries: _timeline),
                  const Gap(AppSpacing.lg),
                  SemanticButton(label: 'Duplicate', type: SemanticButtonType.secondary, onPressed: () async {
                    final user = ref.read(authControllerProvider).user;
                    if (user == null) return;
                    await ref.read(productCatalogServiceProvider).duplicateProduct(user: user, source: product);
                    if (mounted) showSuccessDialog(context, message: 'Product duplicated');
                  }),
                  const Gap(AppSpacing.sm),
                  SemanticButton(label: 'Archive', type: SemanticButtonType.danger, onPressed: () async {
                    final user = ref.read(authControllerProvider).user;
                    if (user == null) return;
                    await ref.read(productCatalogServiceProvider).archiveProduct(user: user, product: product);
                    if (mounted) context.pop();
                  }),
                ],
              ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
