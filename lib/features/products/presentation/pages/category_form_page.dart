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
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/category.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';

class CategoryFormPage extends ConsumerStatefulWidget {
  const CategoryFormPage({this.categoryId, this.parentId, super.key});

  final String? categoryId;
  final String? parentId;

  @override
  ConsumerState<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends ConsumerState<CategoryFormPage> {
  final _name = TextEditingController();
  final _icon = TextEditingController();
  final _sort = TextEditingController(text: '0');
  bool _active = true;
  bool _loading = false;
  String? _error;
  Category? _existing;
  String? _parentId;

  @override
  void initState() {
    super.initState();
    _parentId = widget.parentId;
    if (widget.categoryId != null) Future.microtask(_load);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final user = ref.read(authControllerProvider).user;
    final result = await ref.read(categoryCatalogServiceProvider).getById(widget.categoryId!, user: user);
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _loading = false;
        _error = result.failureOrNull?.message;
      });
      return;
    }
    final c = result.dataOrNull!;
    _existing = c;
    _name.text = c.name;
    _icon.text = c.iconName ?? '';
    _sort.text = c.sortOrder.toString();
    _active = c.isActive;
    _parentId = c.parentId;
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
    final draft = Category(
      id: _existing?.id ?? '',
      tenantId: user.tenantId ?? '',
      name: _name.text.trim(),
      parentId: _parentId,
      iconName: _icon.text.trim().isEmpty ? null : _icon.text.trim(),
      sortOrder: int.tryParse(_sort.text) ?? 0,
      isActive: _active,
      version: _existing?.version ?? 1,
      createdAt: _existing?.createdAt ?? now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final service = ref.read(categoryCatalogServiceProvider);
    final result = _existing == null
        ? await service.create(user: user, draft: draft)
        : await service.update(user: user, category: draft, previous: _existing);
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
    _icon.dispose();
    _sort.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = ref.watch(permissionCheckProvider(CategoryPermissions.manage));
    return AppScaffold(
      appBar: AppAppBar(title: Text(widget.categoryId == null ? 'New Category' : 'Edit Category')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            AppTextField(label: 'Name', controller: _name),
            const Gap(AppSpacing.md),
            AppTextField(label: 'Icon name', controller: _icon, hint: 'e.g. folder_outlined'),
            const Gap(AppSpacing.md),
            AppNumberField(controller: _sort, label: 'Sort order', allowDecimal: false),
            const Gap(AppSpacing.md),
            SwitchListTile(title: const Text('Active'), value: _active, onChanged: (v) => setState(() => _active = v)),
            const Gap(AppSpacing.xl),
            if (canSave)
              SemanticButton(label: 'Save Category', isLoading: _loading, isExpanded: true, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
