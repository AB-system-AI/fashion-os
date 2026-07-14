import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/import_export/import_export_service.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/dialogs/app_dialogs.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/states/app_state_widgets.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';

class ProductImportPage extends ConsumerStatefulWidget {
  const ProductImportPage({super.key});

  @override
  ConsumerState<ProductImportPage> createState() => _ProductImportPageState();
}

class _ProductImportPageState extends ConsumerState<ProductImportPage> {
  final _content = TextEditingController();
  bool _loading = false;
  ImportValidationReport? _preview;
  ImportFormat _format = ImportFormat.csv;

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<void> _previewImport() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    setState(() => _loading = true);
    final result = await ref.read(productCatalogServiceProvider).previewImport(
          user: user,
          content: _content.text,
          format: _format,
        );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _preview = result.dataOrNull;
    });
    if (result.isFailure) showErrorDialog(context, message: result.failureOrNull?.message ?? 'Preview failed');
  }

  Future<void> _import() async {
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    setState(() => _loading = true);
    final result = await ref.read(productCatalogServiceProvider).importWithRollback(
          user: user,
          content: _content.text,
          format: _format,
        );
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isFailure) {
      showErrorDialog(context, message: result.failureOrNull?.message ?? 'Import failed');
      return;
    }
    showSuccessDialog(context, message: 'Imported ${result.dataOrNull!.importedRows} rows');
  }

  Future<void> _exportCsv() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    setState(() => _loading = true);
    final result = await ref.read(productCatalogServiceProvider).exportCsv(user: user!, tenantId: user.tenantId!);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isSuccess) _content.text = utf8.decode(result.dataOrNull!.bytes);
  }

  Future<void> _exportExcel() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    setState(() => _loading = true);
    final result = await ref.read(productCatalogServiceProvider).exportExcel(user: user!, tenantId: user.tenantId!);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isSuccess) _content.text = utf8.decode(result.dataOrNull!.bytes);
  }

  Future<void> _exportPdf() async {
    final user = ref.read(authControllerProvider).user;
    if (user?.tenantId == null) return;
    setState(() => _loading = true);
    final result = await ref.read(productCatalogServiceProvider).exportPdfCatalog(user: user!, tenantId: user.tenantId!);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isSuccess) showSuccessDialog(context, message: 'PDF catalog generated (${result.dataOrNull!.bytes.length} bytes)');
  }

  @override
  Widget build(BuildContext context) {
    final canImport = ref.watch(permissionCheckProvider(ProductPermissions.import));
    final canExport = ref.watch(permissionCheckProvider(ProductPermissions.export));
    if (!canImport && !canExport) {
      return const AppScaffold(body: PermissionDeniedWidget(permission: ProductPermissions.import));
    }

    return AppScaffold(
      appBar: const AppAppBar(title: Text('Import / Export')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<ImportFormat>(
              segments: const [
                ButtonSegment(value: ImportFormat.csv, label: Text('CSV')),
                ButtonSegment(value: ImportFormat.excel, label: Text('Excel')),
              ],
              selected: {_format},
              onSelectionChanged: (s) => setState(() => _format = s.first),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: TextField(
                controller: _content,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ),
            if (_preview != null) ...[
              const Gap(AppSpacing.sm),
              Text('Validation: ${_preview!.validRows}/${_preview!.totalRows} valid, ${_preview!.issues.length} issues'),
              if (_preview!.duplicateSkus.isNotEmpty)
                Text('Duplicates: ${_preview!.duplicateSkus.join(', ')}'),
            ],
            const Gap(AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (canImport) SemanticButton(label: 'Preview', isLoading: _loading, onPressed: _previewImport),
                if (canImport) SemanticButton(label: 'Import', onPressed: _import),
                if (canExport) SemanticButton(label: 'Export CSV', type: SemanticButtonType.secondary, onPressed: _exportCsv),
                if (canExport) SemanticButton(label: 'Export Excel', type: SemanticButtonType.secondary, onPressed: _exportExcel),
                if (canExport) SemanticButton(label: 'Export PDF', type: SemanticButtonType.secondary, onPressed: _exportPdf),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
