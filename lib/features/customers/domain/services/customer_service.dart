import 'package:uuid/uuid.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/engines/barcode_engine.dart';
import 'package:fashion_pos_enterprise/core/business/engines/number_generator_engine.dart';
import 'package:fashion_pos_enterprise/core/business/events/business_events.dart';
import 'package:fashion_pos_enterprise/core/business/events/domain_event_bus.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/pagination/paginated_result.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_codes.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/entities/customer.dart';
import 'package:fashion_pos_enterprise/features/customers/domain/repositories/customer_repositories.dart';

class CustomerService {
  CustomerService({
    required CustomerRepository repository,
    required AuditService auditService,
    required PermissionEngine permissionEngine,
    required NumberGeneratorEngine numberGenerator,
    required BarcodeEngine barcodeEngine,
    DomainEventBus? eventBus,
    Uuid? uuid,
  })  : _repository = repository,
        _audit = auditService,
        _permissions = permissionEngine,
        _numbers = numberGenerator,
        _barcode = barcodeEngine,
        _eventBus = eventBus,
        _uuid = uuid ?? const Uuid();

  final CustomerRepository _repository;
  final AuditService _audit;
  final PermissionEngine _permissions;
  final NumberGeneratorEngine _numbers;
  final BarcodeEngine _barcode;
  final DomainEventBus? _eventBus;
  final Uuid _uuid;

  Future<PaginatedResult<Customer>> list({
    required String tenantId,
    String? search,
    bool? activeOnly,
    String? groupId,
    int page = 1,
    int pageSize = 100,
  }) async {
    final result = await _repository.getPage(
      RepositoryQuery(tenantId: tenantId, search: search, page: page, pageSize: pageSize, sortBy: 'name'),
    );
    var items = result.items;
    if (activeOnly == true) items = items.where((c) => c.active).toList();
    if (groupId != null) items = items.where((c) => c.groupId == groupId).toList();
    return PaginatedResult(
      items: items,
      page: result.page,
      pageSize: result.pageSize,
      totalCount: result.totalCount,
      hasMore: result.hasMore,
    );
  }

  Future<Result<Customer>> getById(String id, {AuthUser? user}) async {
    if (user != null) {
      try {
        _permissions.require(user, CustomerPermissions.view);
      } on PermissionDeniedException catch (e) {
        return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
      }
    }
    final customer = await _repository.getById(id, tenantId: user?.tenantId);
    if (customer == null) {
      return const Error(ValidationFailure(message: 'Customer not found', code: 'not_found'));
    }
    return Success(customer);
  }

  Future<Result<Customer>> create({required AuthUser user, required Customer draft}) async {
    try {
      _permissions.require(user, CustomerPermissions.create);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final tenantId = user.tenantId ?? draft.tenantId;
    final codeResult = draft.customerCode.isNotEmpty
        ? Success(draft.customerCode)
        : (await _numbers.next(type: DocumentNumberType.customer, tenantId: tenantId)).map((n) => n.value);
    if (codeResult.isFailure) return Error(codeResult.failureOrNull!);

    final barcodeResult = _barcode.generate(
      format: BarcodeFormat.customSku,
      value: codeResult.dataOrNull!,
      skuPrefix: 'MBR',
    );
    final barcode = draft.membershipBarcode ??
        barcodeResult.dataOrNull?.value ??
        'MBR-${codeResult.dataOrNull}';

    final now = DateTime.now().toUtc();
    final customer = Customer(
      id: draft.id.isEmpty ? _uuid.v4() : draft.id,
      tenantId: tenantId,
      customerCode: codeResult.dataOrNull!,
      firstName: draft.firstName.trim(),
      lastName: draft.lastName?.trim(),
      phone: draft.phone,
      mobile: draft.mobile,
      email: draft.email,
      gender: draft.gender,
      birthDate: draft.birthDate,
      address: draft.address,
      city: draft.city,
      country: draft.country,
      notes: draft.notes,
      tags: draft.tags,
      groupId: draft.groupId,
      loyaltyTier: draft.loyaltyTier ?? 'standard',
      membershipBarcode: barcode,
      version: 1,
      createdAt: now,
      updatedAt: now,
      syncStatus: LocalSyncStatus.pending,
      isDirty: true,
    );

    final created = await _repository.create(customer);
    await _audit.log(
      action: AuditAction.create,
      entityType: Customer.entityTypeName,
      tenantId: created.tenantId,
      employeeId: user.employeeId,
      entityId: created.id,
      newValue: created.toPayload(),
    );
    _eventBus?.publish(
      CustomerCreatedEvent(
        eventId: _uuid.v4(),
        occurredAt: now,
        customerId: created.id,
        tenantId: tenantId,
      ),
    );
    return Success(created);
  }

  Future<Result<Customer>> update({
    required AuthUser user,
    required Customer customer,
    Customer? previous,
  }) async {
    try {
      _permissions.require(user, CustomerPermissions.update);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }

    final updated = await _repository.update(
      customer.copyWith(
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
    await _audit.log(
      action: AuditAction.update,
      entityType: Customer.entityTypeName,
      tenantId: updated.tenantId,
      employeeId: user.employeeId,
      entityId: updated.id,
      oldValue: previous?.toPayload(),
      newValue: updated.toPayload(),
    );
    return Success(updated);
  }

  Future<Result<Customer>> archive({required AuthUser user, required Customer customer}) {
    return update(user: user, customer: customer.copyWith(active: false), previous: customer);
  }

  Future<Result<void>> delete({required AuthUser user, required String customerId}) async {
    try {
      _permissions.require(user, CustomerPermissions.delete);
    } on PermissionDeniedException catch (e) {
      return Error(ValidationFailure(message: e.toString(), code: 'permission_denied'));
    }
    await _repository.softDelete(customerId, tenantId: user.tenantId);
    await _audit.log(
      action: AuditAction.delete,
      entityType: Customer.entityTypeName,
      tenantId: user.tenantId,
      employeeId: user.employeeId,
      entityId: customerId,
    );
    return const Success(null);
  }
}
