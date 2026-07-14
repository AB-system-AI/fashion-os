import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer_activity.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/enums/customer_enums.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/repositories/customer_repositories.dart';

class CustomerHistoryService {
  CustomerHistoryService({
    required CustomerActivityRepository activityRepository,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    Uuid? uuid,
  })  : _activities = activityRepository,
        _audit = auditService,
        _permissions = permissionEngine,
        _uuid = uuid ?? const Uuid();

  final CustomerActivityRepository _activities;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final Uuid _uuid;

  Future<List<CustomerActivity>> timeline(String tenantId, String customerId) {
    return _activities.listByCustomer(tenantId, customerId);
  }

  Future<Result<CustomerActivity>> addNote({
    required AuthUser user,
    required String customerId,
    required String title,
    String? body,
  }) => _record(
        user: user,
        customerId: customerId,
        type: CustomerActivityType.note,
        title: title,
        body: body,
      );

  Future<Result<CustomerActivity>> recordVisit({
    required AuthUser user,
    required String customerId,
    String? notes,
  }) => _record(
        user: user,
        customerId: customerId,
        type: CustomerActivityType.visit,
        title: 'Store visit',
        body: notes,
      );

  Future<Result<CustomerActivity>> recordCommunication({
    required AuthUser user,
    required String customerId,
    required String title,
    String? body,
  }) => _record(
        user: user,
        customerId: customerId,
        type: CustomerActivityType.communication,
        title: title,
        body: body,
      );

  Future<Result<CustomerActivity>> addFavoriteProducts({
    required AuthUser user,
    required String customerId,
    required List<String> productIds,
  }) async {
    try {
      _permissions.require(user, CustomerPermissions.update);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final now = DateTime.now().toUtc();
    final activity = CustomerActivity(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      customerId: customerId,
      activityType: CustomerActivityType.note,
      title: 'Favorite products updated',
      favoriteProductIds: productIds,
      employeeId: user.employeeId,
      occurredAt: now,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final created = await _activities.create(activity);
    await _audit.log(
      action: AuditAction.create,
      entityType: CustomerActivity.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
    );
    return Success(created);
  }

  Future<Result<CustomerActivity>> _record({
    required AuthUser user,
    required String customerId,
    required CustomerActivityType type,
    required String title,
    String? body,
  }) async {
    try {
      _permissions.require(user, CustomerPermissions.update);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final now = DateTime.now().toUtc();
    final activity = CustomerActivity(
      id: _uuid.v4(),
      tenantId: user.tenantId!,
      customerId: customerId,
      activityType: type,
      title: title,
      body: body,
      employeeId: user.employeeId,
      occurredAt: now,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );
    final created = await _activities.create(activity);
    await _audit.log(
      action: AuditAction.create,
      entityType: CustomerActivity.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
      metadata: {'type': type.value},
    );
    return Success(created);
  }
}
