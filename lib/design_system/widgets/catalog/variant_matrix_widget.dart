import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/design_system/components/catalog_inputs.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/product_variant.dart';

/// Editable variant matrix preview before save.
class VariantMatrixWidget extends StatelessWidget {
  const VariantMatrixWidget({
    required this.variants,
    required this.onChanged,
    this.onGenerate,
    super.key,
  });

  final List<ProductVariant> variants;
  final ValueChanged<List<ProductVariant>> onChanged;
  final VoidCallback? onGenerate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text('Variants (${variants.length})', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            if (onGenerate != null)
              FilledButton.tonal(onPressed: onGenerate, child: const Text('Generate Matrix')),
          ],
        ),
        const Gap(AppSpacing.md),
        if (variants.isEmpty)
          const Text('No variants yet. Use Generate Matrix to create combinations.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: variants.length,
            separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
            itemBuilder: (context, index) => _VariantRowEditor(
              key: ValueKey(variants[index].id),
              variant: variants[index],
              onChanged: (v) {
                final next = List<ProductVariant>.from(variants)..[index] = v;
                onChanged(next);
              },
            ),
          ),
      ],
    );
  }
}

class _VariantRowEditor extends StatefulWidget {
  const _VariantRowEditor({required this.variant, required this.onChanged, super.key});

  final ProductVariant variant;
  final ValueChanged<ProductVariant> onChanged;

  @override
  State<_VariantRowEditor> createState() => _VariantRowEditorState();
}

class _VariantRowEditorState extends State<_VariantRowEditor> {
  late final TextEditingController _sku;
  late final TextEditingController _barcode;
  late final TextEditingController _retail;
  late final TextEditingController _stock;

  @override
  void initState() {
    super.initState();
    _sku = TextEditingController(text: widget.variant.sku);
    _barcode = TextEditingController(text: widget.variant.barcode ?? '');
    _retail = TextEditingController(text: widget.variant.retailPriceOverride?.toString() ?? '');
    _stock = TextEditingController(text: widget.variant.stockQuantity.toString());
  }

  @override
  void dispose() {
    _sku.dispose();
    _barcode.dispose();
    _retail.dispose();
    _stock.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      widget.variant.copyWith(
        sku: _sku.text.trim(),
        barcode: _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
        retailPriceOverride: double.tryParse(_retail.text),
        stockQuantity: double.tryParse(_stock.text) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.variant;
    final label = [v.color, v.size, v.material, v.pattern, v.style].whereType<String>().where((e) => e.isNotEmpty).join(' / ');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.isEmpty ? v.sku : label, style: Theme.of(context).textTheme.titleSmall),
            const Gap(AppSpacing.sm),
            AppBarcodeField(controller: _sku, label: 'SKU', onChanged: (_) => _emit()),
            const Gap(AppSpacing.sm),
            AppBarcodeField(controller: _barcode, label: 'Barcode', onChanged: (_) => _emit()),
            const Gap(AppSpacing.sm),
            Row(
              children: [
                Expanded(child: AppCurrencyField(controller: _retail, label: 'Retail', onChanged: (_) => _emit())),
                const Gap(AppSpacing.sm),
                Expanded(child: AppNumberField(controller: _stock, label: 'Stock', onChanged: (_) => _emit())),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
