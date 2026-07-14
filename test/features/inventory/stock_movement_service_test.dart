import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fashion_pos_enterprise/core/audit/audit_service.dart';
import 'package:fashion_pos_enterprise/core/business/engines/inventory/inventory_engine.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/models/sync_enums.dart';
import 'package:fashion_pos_enterprise/core/permissions/permission_engine.dart';
import 'package:fashion_pos_enterprise/features/auth/domain/entities/auth_user.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/entities/stock_level.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/repositories/inventory_repositories.dart';
import 'package:fashion_pos_enterprise/features/inventory/domain/services/stock_movement_service.dart';

class _MockStockLevelRepository extends Mock implements StockLevelRepository {}

class _MockStockMovementRepository extends Mock implements StockMovementRepository {}

class _MockAuditService extends Mock implements AuditService {}

void main() {
  late StockMovementService service;
  late _MockStockLevelRepository levels;
  late _MockStockMovementRepository movements;
  late _MockAuditService audit;

  const user = AuthUser(
    userId: 'u1',
    employeeId: 'e1',
    email: 'a@b.com',
    emailVerified: true,
    tenantId: 't1',
    permissions: {'inventory.movement'},
  );

  setUpAll(() {
    registerFallbackValue(
      StockLevel(
        id: 'l1',
        tenantId: 't1',
        warehouseId: 'w1',
        productId: 'p1',
        onHand: 0,
        reserved: 0,
        version: 1,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
        syncStatus: LocalSyncStatus.pending,
        isDirty: true,
      ),
    );
  });

  setUp(() {
    levels = _MockStockLevelRepository();
    movements = _MockStockMovementRepository();
    audit = _MockAuditService();
    service = StockMovementService(
      stockLevelRepository: levels,
      movementRepository: movements,
      inventoryEngine: InventoryEngine(),
      auditService: audit,
      permissionEngine: const PermissionEngine(),
    );

    when(() => audit.log(
          action: any(named: 'action'),
          entityType: any(named: 'entityType'),
          tenantId: any(named: 'tenantId'),
          employeeId: any(named: 'employeeId'),
          entityId: any(named: 'entityId'),
          metadata: any(named: 'metadata'),
        )).thenAnswer((_) async {});
  });

  test('receiveStock denies without permission', () async {
    final denied = await service.receiveStock(
      user: const AuthUser(
        userId: 'u1',
        email: 'a@b.com',
        emailVerified: true,
        permissions: const {},
      ),
      warehouseId: 'w1',
      productId: 'p1',
      quantity: 5,
    );
    expect(denied.isFailure, isTrue);
  });
}
