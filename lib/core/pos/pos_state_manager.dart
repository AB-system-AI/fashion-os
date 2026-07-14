import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/database_initializer.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';
import 'package:fashion_pos_enterprise/core/pos/pos_models.dart';
import 'package:uuid/uuid.dart';

/// Auto-saves POS state as syncable local records for crash recovery.
class PosStateManager {
  PosStateManager({
    Uuid? uuid,
    this.autoSaveDebounce = const Duration(milliseconds: 300),
  }) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;
  final Duration autoSaveDebounce;

  Timer? _cartSaveTimer;
  Timer? _sessionSaveTimer;

  static const String _cartEntityType = 'pos_cart';
  static const String _sessionEntityType = 'pos_cash_session';
  static const String _saleEntityType = 'sale';

  Future<PosRecoveryBundle> recoverState({
    required String storeId,
    required String employeeId,
  }) async {
    final db = DatabaseInitializer.database;
    final cartQuery = await (db.select(db.syncableRecords)
          ..where((t) => t.entityType.equals(_cartEntityType))
          ..where((t) => t.storeId.equals(storeId))
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.payload.like('%\"employee_id\":\"$employeeId\"%')))
        .get();

    final sessionQuery = await (db.select(db.syncableRecords)
          ..where((t) => t.entityType.equals(_sessionEntityType))
          ..where((t) => t.storeId.equals(storeId))
          ..where((t) => t.deletedAt.isNull()))
        .get();

    final pendingSales = await (db.select(db.syncableRecords)
          ..where((t) => t.entityType.equals(_saleEntityType))
          ..where((t) => t.storeId.equals(storeId))
          ..where((t) => t.syncStatus.isIn(['pending', 'draft'])))
        .get();

    PosCartSnapshot? cart;
    if (cartQuery.isNotEmpty) {
      final data = jsonDecode(cartQuery.first.payload) as Map<String, dynamic>;
      cart = PosCartSnapshot.fromJson(data);
    }

    PosCashSessionSnapshot? session;
    if (sessionQuery.isNotEmpty) {
      final data = jsonDecode(sessionQuery.first.payload) as Map<String, dynamic>;
      session = PosCashSessionSnapshot.fromJson(data);
    }

    final pendingIds = pendingSales.map((r) => r.id).toList();

    if (cart != null || session != null || pendingIds.isNotEmpty) {
      AppLogger.info(
        'POS recovery: cart=${cart != null}, session=${session != null}, pending=${pendingIds.length}',
      );
    }

    return PosRecoveryBundle(
      activeCart: cart,
      openCashSession: session,
      pendingSaleIds: pendingIds,
    );
  }

  void scheduleCartSave(PosCartSnapshot cart) {
    _cartSaveTimer?.cancel();
    _cartSaveTimer = Timer(autoSaveDebounce, () {
      unawaited(_saveCart(cart));
    });
  }

  Future<void> _saveCart(PosCartSnapshot cart) async {
    final db = DatabaseInitializer.database;
    final now = DateTime.now().toUtc();
    await db.syncableRecordDao.insertRecord(
      SyncableRecordsCompanion.insert(
        id: cart.id,
        tenantId: cart.tenantId,
        entityType: _cartEntityType,
        storeId: Value(cart.storeId),
        payload: jsonEncode(cart.toJson()),
        version: const Value(1),
        createdAt: now,
        updatedAt: now,
        syncStatus: const Value('pending'),
        isDirty: const Value(true),
        searchName: const Value('pos_cart'),
      ),
    );
  }

  void scheduleCashSessionSave(PosCashSessionSnapshot session) {
    _sessionSaveTimer?.cancel();
    _sessionSaveTimer = Timer(autoSaveDebounce, () {
      unawaited(_saveCashSession(session));
    });
  }

  Future<void> _saveCashSession(PosCashSessionSnapshot session) async {
    final db = DatabaseInitializer.database;
    final now = DateTime.now().toUtc();
    await db.syncableRecordDao.insertRecord(
      SyncableRecordsCompanion.insert(
        id: session.id,
        tenantId: session.tenantId,
        entityType: _sessionEntityType,
        storeId: Value(session.storeId),
        payload: jsonEncode(session.toJson()),
        version: const Value(1),
        createdAt: now,
        updatedAt: now,
        syncStatus: const Value('pending'),
        isDirty: const Value(true),
        searchName: const Value('pos_session'),
      ),
    );
  }

  Future<String> createCartId() async => _uuid.v4();

  Future<String> createSessionId() async => _uuid.v4();

  void dispose() {
    _cartSaveTimer?.cancel();
    _sessionSaveTimer?.cancel();
  }
}
