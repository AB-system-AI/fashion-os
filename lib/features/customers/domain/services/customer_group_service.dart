import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_group.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/repositories/customer_repositories.dart';

class CustomerGroupService {
  CustomerGroupService({
    required CustomerGroupRepository repository,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    Uuid? uuid,
  })  : _repository = repository,
        _audit = auditService,
        _permissions = permissionEngine,
        _uuid = uuid ?? const Uuid();

  final CustomerGroupRepository _repository;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<Result<CustomerGroup>> create({required AuthUser user, required CustomerGroup draft}) async {
    try {
      _permissions.require(user, CustomerPermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final now = DateTime.now().toUtc();
    final group = CustomerGroup(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      tenantId: user.tenantId ?? draft.tenantId,
      name: draft.name.trim(),
      code: draft.code,
      description: draft.description,
      pricingRule: draft.pricingRule,
      discountPercent: draft.discountPercent,
      loyaltyMultiplier: draft.loyaltyMultiplier,
      creditLimit: draft.creditLimit,
      badgeColor: draft.badgeColor,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final created = await _repository.create(group);
    await _audit.log(
      action: AuditAction.create,
      entityType: CustomerGroup.entityTypeName,
      tenantId: created.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
      newValue: created.toPayload(),
    );
    return Success(created);
  }

  Future<List<CustomerGroup>> list(String tenantId) async {
    final page = await _repository.getPage(
      RepositoryQuery(tenantId: tenantId, pageSize: 100, sortBy: 'sort_order'),
    );
    return page.items;
  }
}
