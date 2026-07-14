import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fashion_pos_enterprise/design_system/components/app_text_field.dart';

/// Debounced search field for catalog lists.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    required this.onSearch,
    this.hint = 'Search…',
    this.debounce = const Duration(milliseconds: 300),
    this.autofocus = false,
    super.key,
  });

  final ValueChanged<String> onSearch;
  final String hint;
  final Duration debounce;
  final bool autofocus;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  Timer? _debounce;
  final _controller = TextEditingController();

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounce, () => widget.onSearch(value));
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _controller,
      hint: widget.hint,
      autofocus: widget.autofocus,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: _controller.text.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                widget.onSearch('');
              },
            )
          : null,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
    );
  }
}

/// Numeric input with optional decimal places.
class AppNumberField extends StatelessWidget {
  const AppNumberField({
    this.controller,
    this.label,
    this.allowDecimal = true,
    this.onChanged,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final bool allowDecimal;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        if (allowDecimal)
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
        else
          FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: onChanged,
    );
  }
}

/// Currency amount input (major units).
class AppCurrencyField extends StatelessWidget {
  const AppCurrencyField({
    this.controller,
    this.label,
    this.currencySymbol = '\$',
    this.onChanged,
    super.key,
  });

  final TextEditingController? controller;
  final String? label;
  final String currencySymbol;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 12, top: 12),
        child: Text(currencySymbol, style: Theme.of(context).textTheme.titleMedium),
      ),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
      onChanged: onChanged,
    );
  }
}

/// Percentage input (0–100).
class AppPercentageField extends StatelessWidget {
  const AppPercentageField({this.controller, this.label, this.onChanged, super.key});

  final TextEditingController? controller;
  final String? label;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      suffixIcon: const Padding(
        padding: EdgeInsets.only(right: 12, top: 12),
        child: Text('%'),
      ),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
      onChanged: onChanged,
    );
  }
}

/// Barcode / SKU scanner-ready text field.
class AppBarcodeField extends StatelessWidget {
  const AppBarcodeField({
    this.controller,
    this.label = 'Barcode',
    this.onChanged,
    this.onScan,
    super.key,
  });

  final TextEditingController? controller;
  final String label;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: label,
      onChanged: onChanged,
      suffixIcon: onScan != null
          ? IconButton(icon: const Icon(Icons.qr_code_scanner), onPressed: onScan)
          : null,
      textInputAction: TextInputAction.done,
    );
  }
}
