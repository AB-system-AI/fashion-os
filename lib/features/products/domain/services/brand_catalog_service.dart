import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/products/domain/entities/brand.dart';
import 'package:fashion_pos_enterprise/features/products/domain/repositories/product_repositories.dart';

/// Brand master data domain service.
class BrandCatalogService {
  BrandCatalogService({
    required BrandRepository repository,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    Uuid? uuid,
  })  : _repository = repository,
        _audit = auditService,
        _permissions = permissionEngine,
        _uuid = uuid ?? const Uuid();

  final BrandRepository _repository;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<PaginatedResult<Brand>> list({
    required String tenantId,
    int page = 1,
    int pageSize = 500,
  }) {
    return _repository.getPage(
      RepositoryQuery(tenantId: tenantId, page: page, pageSize: pageSize, sortBy: 'name'),
    );
  }

  Future<Result<Brand>> getById(String id, {AuthUser? user}) async {
    if (user != null) {
      try {
        _permissions.require(user, BrandPermissions.read);
      } on PermissionDeniedException catch (e) {
        return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
      }
    }
    final brand = await _repository.getById(id, tenantId: user?.tenantId);
    if (brand == null) {
      return const Error(ValidationFailure(message: 'Brand not found', code: 'not_found'));
    }
    return Success(brand);
  }

  Future<Result<Brand>> create({required AuthUser user, required Brand draft}) async {
    try {
      _permissions.require(user, BrandPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final now = DateTime.now().toUtc();
    final brand = Brand(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      tenantId: user.tenantId ?? draft.tenantId,
      name: draft.name.trim(),
      logoAssetId: draft.logoAssetId,
      country: draft.country,
      description: draft.description,
      isActive: draft.isActive,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final created = await _repository.create(brand);
    await _audit.log(
      action: AuditAction.create,
      entityType: Brand.entityTypeName,
      tenantId: created.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
      newValue: created.toPayload(),
    );
    return Success(created);
  }

  Future<Result<Brand>> update({
    required AuthUser user,
    required Brand brand,
    Brand? previous,
  }) async {
    try {
      _permissions.require(user, BrandPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final updated = await _repository.update(
      brand.copyWith(updatedAt: DateTime.now().toUtc(), syncStatus: LocalSyncStatus.pending, isDirty: true),
    );
    await _audit.log(
      action: AuditAction.update,
      entityType: Brand.entityTypeName,
      tenantId: updated.tenantId,
      employeeId: user.employeeId,
      entityId: updated.id,
      oldValue: previous?.toPayload(),
      newValue: updated.toPayload(),
    );
    return Success(updated);
  }

  Future<Result<void>> delete({required AuthUser user, required String brandId}) async {
    try {
      _permissions.require(user, BrandPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    await _repository.softDelete(brandId);
    await _audit.log(
      action: AuditAction.delete,
      entityType: Brand.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: brandId,
    );
    return const Success(null);
  }

  Future<Result<Brand>> restore({required AuthUser user, required String brandId}) async {
    try {
      _permissions.require(user, BrandPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    await _repository.restore(brandId, tenantId: user.tenantId);
    final restored = await _repository.getById(brandId, tenantId: user.tenantId);
    if (restored == null) {
      return const Error(ValidationFailure(message: 'Brand not found', code: 'not_found'));
    }
    await _audit.log(
      action: AuditAction.update,
      entityType: Brand.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: brandId,
      metadata: {'action': 'restore'},
    );
    return Success(restored);
  }

  Future<Result<Brand>> archive({required AuthUser user, required Brand brand}) {
    return update(user: user, brand: brand.copyWith(isActive: false), previous: brand);
  }
}
