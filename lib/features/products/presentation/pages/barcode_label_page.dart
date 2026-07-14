import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product.dart';
import 'package:fashion_pos_enterprise/features/products/domain/services/barcode_label_print_service.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';

/// Barcode label preview and batch printing via printer abstraction.
class BarcodeLabelPage extends ConsumerStatefulWidget {
  const BarcodeLabelPage({required this.productId, super.key});

  final String productId;

  @override
  ConsumerState<BarcodeLabelPage> createState() => _BarcodeLabelPageState();
}

class _BarcodeLabelPageState extends ConsumerState<BarcodeLabelPage> {
  Product? _product;
  bool _loading = true;
  String? _error;
  Uint8List? _previewBytes;
  BarcodeLabelLayout _layout = BarcodeLabelLayout.standard;
  String _format = 'code128';
  int _copies = 1;
  bool _batchVariants = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final user = ref.read(authControllerProvider).user;
    final result = await ref.read(productCatalogServiceProvider).getById(widget.productId, user: user);
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _loading = false;
        _error = result.failureOrNull?.message;
      });
      return;
    }
    setState(() {
      _loading = false;
      _product = result.dataOrNull;
    });
    await _generatePreview();
  }

  Future<void> _generatePreview() async {
    final user = ref.read(authControllerProvider).user;
    final product = _product;
    if (user == null || product == null) return;

    setState(() => _busy = true);
    final service = ref.read(barcodeLabelPrintServiceProvider);
    final result = await service.previewLabel(
      user: user,
      product: product,
      layout: _layout,
      format: _format,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _previewBytes = result.isSuccess ? Uint8List.fromList(result.dataOrNull!) : null;
      if (result.isFailure) _error = result.failureOrNull?.message;
    });
  }

  Future<void> _print() async {
    final user = ref.read(authControllerProvider).user;
    final product = _product;
    if (user == null || product == null) return;

    setState(() => _busy = true);
    final service = ref.read(barcodeLabelPrintServiceProvider);
    final variants = _batchVariants && product.variants.isNotEmpty ? product.variants : null;
    final result = await service.printLabels(
      user: user,
      product: product,
      variants: variants,
      layout: _layout,
      format: _format,
      copiesPerLabel: _copies,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (result.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Labels sent to printer')));
    } else {
      setState(() => _error = result.failureOrNull?.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    return AppScaffold(
      appBar: AppAppBar(title: Text(product?.name ?? 'Barcode Labels')),
      body: AppStateView(
        isLoading: _loading,
        error: _error,
        isEmpty: product == null && !_loading,
        onRetry: _load,
        child: product == null
            ? const SizedBox()
            : ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  DropdownButtonFormField<BarcodeLabelLayout>(
                    value: _layout,
                    decoration: const InputDecoration(labelText: 'Layout'),
                    items: BarcodeLabelLayout.values
                        .map((l) => DropdownMenuItem(value: l, child: Text(l.name)))
                        .toList(),
                    onChanged: _busy
                        ? null
                        : (v) async {
                            if (v == null) return;
                            setState(() => _layout = v);
                            await _generatePreview();
                          },
                  ),
                  const Gap(AppSpacing.md),
                  DropdownButtonFormField<String>(
                    value: _format,
                    decoration: const InputDecoration(labelText: 'Barcode format'),
                    items: const [
                      DropdownMenuItem(value: 'code128', child: Text('Code 128')),
                      DropdownMenuItem(value: 'ean13', child: Text('EAN-13')),
                      DropdownMenuItem(value: 'qr', child: Text('QR Code')),
                    ],
                    onChanged: _busy
                        ? null
                        : (v) async {
                            if (v == null) return;
                            setState(() => _format = v);
                            await _generatePreview();
                          },
                  ),
                  const Gap(AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: '$_copies',
                          decoration: const InputDecoration(labelText: 'Copies per label'),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => _copies = int.tryParse(v) ?? 1,
                        ),
                      ),
                      const Gap(AppSpacing.md),
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('All variants'),
                          value: _batchVariants,
                          onChanged: _busy ? null : (v) => setState(() => _batchVariants = v),
                        ),
                      ),
                    ],
                  ),
                  const Gap(AppSpacing.lg),
                  Text('Preview', style: Theme.of(context).textTheme.titleMedium),
                  const Gap(AppSpacing.sm),
                  if (_previewBytes != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Image.memory(_previewBytes!, height: 160, fit: BoxFit.contain),
                      ),
                    )
                  else
                    const Text('Preview unavailable'),
                  const Gap(AppSpacing.lg),
                  SemanticButton(
                    label: 'Regenerate Preview',
                    type: SemanticButtonType.secondary,
                    isLoading: _busy,
                    onPressed: _generatePreview,
                  ),
                  const Gap(AppSpacing.sm),
                  SemanticButton(
                    label: 'Print Labels',
                    isLoading: _busy,
                    isExpanded: true,
                    onPressed: _print,
                  ),
                  const Gap(AppSpacing.sm),
                  SemanticButton(
                    label: 'Back',
                    type: SemanticButtonType.secondary,
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
      ),
    );
  }
}
