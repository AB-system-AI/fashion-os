import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:fashion_pos_enterprise/design_system/components/catalog_inputs.dart';
import 'package:fashion_pos_enterprise/design_system/components/catalog_pickers.dart';
import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/features/products/domain/enums/product_enums.dart';
import 'package:fashion_pos_enterprise/features/products/domain/models/product_list_filters.dart';

/// Advanced filter panel for product catalog.
class ProductFilterPanel extends StatefulWidget {
  const ProductFilterPanel({
    required this.initial,
    required this.onApply,
    this.categories = const [],
    this.brands = const [],
    super.key,
  });

  final ProductListFilters initial;
  final ValueChanged<ProductListFilters> onApply;
  final List<String> categories;
  final List<String> brands;

  @override
  State<ProductFilterPanel> createState() => _ProductFilterPanelState();
}

class _ProductFilterPanelState extends State<ProductFilterPanel> {
  late ProductStatus? _status = widget.initial.status;
  late DateTime? _createdAfter = widget.initial.createdAfter;
  late DateTime? _updatedAfter = widget.initial.updatedAfter;
  bool? _hasImage = widget.initial.hasImage;
  bool? _hasVariants = widget.initial.hasVariants;
  final _minPrice = TextEditingController(text: widget.initial.minPrice?.toString() ?? '');
  final _maxPrice = TextEditingController(text: widget.initial.maxPrice?.toString() ?? '');

  @override
  void dispose() {
    _minPrice.dispose();
    _maxPrice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppDropdownField<ProductStatus?>(
          label: 'Status',
          value: _status,
          items: [null, ...ProductStatus.values],
          itemLabel: (s) => s?.name ?? 'Any',
          onChanged: (v) => setState(() => _status = v),
        ),
        const Gap(AppSpacing.md),
        AppCurrencyField(controller: _minPrice, label: 'Min Price'),
        const Gap(AppSpacing.md),
        AppCurrencyField(controller: _maxPrice, label: 'Max Price'),
        const Gap(AppSpacing.md),
        AppDateField(label: 'Created After', value: _createdAfter, onChanged: (v) => setState(() => _createdAfter = v)),
        const Gap(AppSpacing.md),
        AppDateField(label: 'Updated After', value: _updatedAfter, onChanged: (v) => setState(() => _updatedAfter = v)),
        const Gap(AppSpacing.md),
        SwitchListTile(
          title: const Text('Has image'),
          value: _hasImage ?? false,
          tristate: true,
          onChanged: (v) => setState(() => _hasImage = v),
        ),
        SwitchListTile(
          title: const Text('Has variants'),
          value: _hasVariants ?? false,
          tristate: true,
          onChanged: (v) => setState(() => _hasVariants = v),
        ),
        const Gap(AppSpacing.lg),
        SemanticButton(
          label: 'Apply Filters',
          isExpanded: true,
          onPressed: () {
            widget.onApply(
              ProductListFilters(
                status: _status,
                minPrice: double.tryParse(_minPrice.text),
                maxPrice: double.tryParse(_maxPrice.text),
                createdAfter: _createdAfter,
                updatedAfter: _updatedAfter,
                hasImage: _hasImage,
                hasVariants: _hasVariants,
              ),
            );
          },
        ),
      ],
    );
  }
}
