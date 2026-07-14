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
import 'package:fashion_pos_enterprise/features/products/domain/entities/category.dart';
import 'package:fashion_pos_enterprise/features/products/domain/repositories/product_repositories.dart';

/// Category catalog domain service — hierarchy validation and CRUD.
class CategoryCatalogService {
  CategoryCatalogService({
    required CategoryRepository repository,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    Uuid? uuid,
  })  : _repository = repository,
        _audit = auditService,
        _permissions = permissionEngine,
        _uuid = uuid ?? const Uuid();

  final CategoryRepository _repository;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<PaginatedResult<Category>> list({
    required String tenantId,
    int page = 1,
    int pageSize = 500,
  }) {
    return _repository.getPage(
      RepositoryQuery(tenantId: tenantId, page: page, pageSize: pageSize, sortBy: 'sort_order'),
    );
  }

  Future<List<CategoryNode>> tree(String tenantId) async {
    final flat = await _repository.listTree(tenantId);
    final map = {for (final c in flat) c.id: CategoryNode(category: c, children: [])};
    final roots = <CategoryNode>[];
    for (final node in map.values) {
      final parentId = node.category.parentId;
      if (parentId != null && map.containsKey(parentId)) {
        map[parentId]!.children.add(node);
      } else {
        roots.add(node);
      }
    }
    void sortNodes(List<CategoryNode> nodes) {
      nodes.sort((a, b) => a.category.sortOrder.compareTo(b.category.sortOrder));
      for (final n in nodes) {
        sortNodes(n.children);
      }
    }

    sortNodes(roots);
    return roots;
  }

  Future<Result<Category>> getById(String id, {AuthUser? user}) async {
    if (user != null) {
      try {
        _permissions.require(user, CategoryPermissions.read);
      } on PermissionDeniedException catch (e) {
        return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
      }
    }
    final category = await _repository.getById(id, tenantId: user?.tenantId);
    if (category == null) {
      return const Error(ValidationFailure(message: 'Category not found', code: 'not_found'));
    }
    return Success(category);
  }

  Future<Result<Category>> create({
    required AuthUser user,
    required Category draft,
  }) async {
    try {
      _permissions.require(user, CategoryPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    if (draft.parentId != null) {
      final parent = await _repository.getById(draft.parentId!, tenantId: user.tenantId);
      if (parent == null) {
        return const Error(ValidationFailure(message: 'Parent category not found', code: 'invalid_parent'));
      }
    }

    final now = DateTime.now().toUtc();
    final path = await _buildPath(draft.parentId, draft.name, tenantId: user.tenantId);
    final category = Category(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      tenantId: user.tenantId ?? draft.tenantId,
      name: draft.name.trim(),
      parentId: draft.parentId,
      path: path,
      iconName: draft.iconName,
      imageAssetId: draft.imageAssetId,
      sortOrder: draft.sortOrder,
      isActive: draft.isActive,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    final created = await _repository.create(category);
    await _audit.log(
      action: AuditAction.create,
      entityType: Category.entityTypeName,
      tenantId: created.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
      newValue: created.toPayload(),
    );
    return Success(created);
  }

  Future<Result<Category>> update({
    required AuthUser user,
    required Category category,
    Category? previous,
  }) async {
    try {
      _permissions.require(user, CategoryPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    if (category.parentId == category.id) {
      return const Error(ValidationFailure(message: 'Category cannot be its own parent', code: 'invalid_parent'));
    }
    if (category.parentId != null) {
      final invalid = await _isDescendant(category.parentId!, category.id, tenantId: category.tenantId);
      if (invalid) {
        return const Error(ValidationFailure(message: 'Circular category hierarchy', code: 'invalid_parent'));
      }
    }

    final path = await _buildPath(category.parentId, category.name, tenantId: category.tenantId);
    final updated = await _repository.update(
      Category(
        id: category.id,
        tenantId: category.tenantId,
        name: category.name.trim(),
        parentId: category.parentId,
        path: path,
        iconName: category.iconName,
        imageAssetId: category.imageAssetId,
        sortOrder: category.sortOrder,
        isActive: category.isActive,
        version: category.version,
        createdAt: category.createdAt,
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
        deletedAt: category.deletedAt,
      ),
    );
    await _audit.log(
      action: AuditAction.update,
      entityType: Category.entityTypeName,
      tenantId: updated.tenantId,
      employeeId: user.employeeId,
      entityId: updated.id,
      oldValue: previous?.toPayload(),
      newValue: updated.toPayload(),
    );
    return Success(updated);
  }

  Future<Result<void>> delete({required AuthUser user, required String categoryId}) async {
    try {
      _permissions.require(user, CategoryPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    await _repository.softDelete(categoryId);
    await _audit.log(
      action: AuditAction.delete,
      entityType: Category.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: categoryId,
    );
    return const Success(null);
  }

  Future<Result<Category>> restore({required AuthUser user, required String categoryId}) async {
    try {
      _permissions.require(user, CategoryPermissions.manage);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    await _repository.restore(categoryId, tenantId: user.tenantId);
    final restored = await _repository.getById(categoryId, tenantId: user.tenantId);
    if (restored == null) {
      return const Error(ValidationFailure(message: 'Category not found', code: 'not_found'));
    }
    await _audit.log(
      action: AuditAction.update,
      entityType: Category.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: categoryId,
      metadata: {'action': 'restore'},
    );
    return Success(restored);
  }

  Future<Result<Category>> archive({required AuthUser user, required Category category}) {
    return update(user: user, category: category.copyWith(isActive: false), previous: category);
  }

  Future<String> _buildPath(String? parentId, String name, {String? tenantId}) async {
    if (parentId == null) return name;
    final parent = await _repository.getById(parentId, tenantId: tenantId);
    if (parent == null) return name;
    return '${parent.path ?? parent.name}/$name';
  }

  Future<bool> _isDescendant(String candidateParentId, String categoryId, {String? tenantId}) async {
    var current = await _repository.getById(candidateParentId, tenantId: tenantId);
    while (current != null) {
      if (current.id == categoryId) return true;
      if (current.parentId == null) return false;
      current = await _repository.getById(current.parentId!, tenantId: tenantId);
    }
    return false;
  }
}

class CategoryNode {
  CategoryNode({required this.category, required this.children});

  final Category category;
  final List<CategoryNode> children;
}
