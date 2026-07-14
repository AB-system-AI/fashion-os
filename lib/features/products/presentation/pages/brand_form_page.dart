import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_providers.dart';
import 'package:fashion_pos_enterprise/design_system/components/app_text_field.dart';
import 'package:fashion_pos_enterprise/design_system/components/semantic_button.dart';
import 'package:fashion_pos_enterprise/design_system/spacing/app_spacing.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_app_bar.dart';
import 'package:fashion_pos_enterprise/design_system/widgets/app_scaffold.dart';
import 'package:fashion_pos_enterprise/features/auth/presentation/providers/auth_controller.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/brand.dart';
import 'package:fashion_pos_enterprise/features/products/presentation/providers/product_providers.dart';

class BrandFormPage extends ConsumerStatefulWidget {
  const BrandFormPage({this.brandId, super.key});

  final String? brandId;

  @override
  ConsumerState<BrandFormPage> createState() => _BrandFormPageState();
}

class _BrandFormPageState extends ConsumerState<BrandFormPage> {
  final _name = TextEditingController();
  final _country = TextEditingController();
  final _description = TextEditingController();
  bool _active = true;
  bool _loading = false;
  String? _error;
  Brand? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.brandId != null) Future.microtask(_load);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final user = ref.read(authControllerProvider).user;
    final result = await ref.read(brandCatalogServiceProvider).getById(widget.brandId!, user: user);
    if (!mounted) return;
    if (result.isFailure) {
      setState(() {
        _loading = false;
        _error = result.failureOrNull?.message;
      });
      return;
    }
    final b = result.dataOrNull!;
    _existing = b;
    _name.text = b.name;
    _country.text = b.country ?? '';
    _description.text = b.description ?? '';
    _active = b.isActive;
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
    final draft = Brand(
      id: _existing?.id ?? '',
      tenantId: user.tenantId ?? '',
      name: _name.text.trim(),
      country: _country.text.trim().isEmpty ? null : _country.text.trim(),
      description: _description.text.trim().isEmpty ? null : _description.text.trim(),
      isActive: _active,
      version: _existing?.version ?? 1,
      createdAt: _existing?.createdAt ?? now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final service = ref.read(brandCatalogServiceProvider);
    final result = _existing == null
        ? await service.create(user: user, draft: draft)
        : await service.update(user: user, brand: draft, previous: _existing);
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
    _country.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSave = ref.watch(permissionCheckProvider(BrandPermissions.manage));
    return AppScaffold(
      appBar: AppAppBar(title: Text(widget.brandId == null ? 'New Brand' : 'Edit Brand')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_error != null) Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            AppTextField(label: 'Brand Name', controller: _name),
            const Gap(AppSpacing.md),
            AppTextField(label: 'Country', controller: _country),
            const Gap(AppSpacing.md),
            AppTextField(label: 'Description', controller: _description, maxLines: 3),
            const Gap(AppSpacing.md),
            SwitchListTile(title: const Text('Active'), value: _active, onChanged: (v) => setState(() => _active = v)),
            const Gap(AppSpacing.xl),
            if (canSave)
              SemanticButton(label: 'Save Brand', isLoading: _loading, isExpanded: true, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
