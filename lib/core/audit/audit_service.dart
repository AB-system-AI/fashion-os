import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:fashion_pos_enterprise/core/audit/audit_action.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/app_database.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/database/database_initializer.dart';
import 'package:fashion_pos_enterprise/core/logging/app_logger.dart';
import 'package:uuid/uuid.dart';

/// Immutable audit log entry.
class AuditEntry {
  const AuditEntry({
    required this.id,
    required this.action,
    required this.entityType,
    required this.createdAt,
    this.tenantId,
    this.storeId,
    this.employeeId,
    this.deviceId,
    this.entityId,
    this.oldValue,
    this.newValue,
    this.metadata = const {},
    this.synced = false,
  });

  final String id;
  final String? tenantId;
  final String? storeId;
  final String? employeeId;
  final String? deviceId;
  final AuditAction action;
  final String entityType;
  final String? entityId;
  final String? oldValue;
  final String? newValue;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final bool synced;
}

/// Local-first audit trail — syncs to server when online.
class AuditService {
  AuditService({Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final Uuid _uuid;

  AppDatabase get _db => DatabaseInitializer.database;

  Future<void> log({
    required AuditAction action,
    required String entityType,
    String? tenantId,
    String? storeId,
    String? employeeId,
    String? deviceId,
    String? entityId,
    Object? oldValue,
    Object? newValue,
    Map<String, dynamic> metadata = const {},
  }) async {
    final entry = AuditEntry(
      id: _uuid.v4(),
      tenantId: tenantId,
      storeId: storeId,
      employeeId: employeeId,
      deviceId: deviceId,
      action: action,
      entityType: entityType,
      entityId: entityId,
      oldValue: oldValue != null ? _encode(oldValue) : null,
      newValue: newValue != null ? _encode(newValue) : null,
      metadata: metadata,
      createdAt: DateTime.now().toUtc(),
    );

    await _db.auditLogDao.append(
      AuditLogEntriesCompanion.insert(
        id: entry.id,
        tenantId: Value(entry.tenantId),
        storeId: Value(entry.storeId),
        employeeId: Value(entry.employeeId),
        deviceId: Value(entry.deviceId),
        action: entry.action.value,
        entityType: entry.entityType,
        entityId: Value(entry.entityId),
        oldValue: Value(entry.oldValue),
        newValue: Value(entry.newValue),
        metadata: Value(jsonEncode(entry.metadata)),
        createdAt: entry.createdAt,
        synced: const Value(false),
      ),
    );
    AppLogger.debug('Audit: ${action.value} $entityType/$entityId');
  }

  Future<List<AuditEntry>> pendingSync({int limit = 100}) async {
    final rows = await _db.auditLogDao.getUnsynced(limit: limit);
    return rows.map(_fromRow).toList();
  }

  Future<void> markSynced(List<String> ids) async {
    await _db.auditLogDao.markSynced(ids);
  }

  /// Chronological audit history for a single entity (product timeline).
  Future<List<AuditEntry>> getEntityTimeline({
    required String entityType,
    required String entityId,
    int limit = 100,
  }) async {
    final rows = await _db.auditLogDao.getByEntity(
      entityType: entityType,
      entityId: entityId,
      limit: limit,
    );
    return rows.map(_fromRow).toList();
  }

  AuditEntry _fromRow(AuditLogEntry row) {
    return AuditEntry(
      id: row.id,
      tenantId: row.tenantId,
      storeId: row.storeId,
      employeeId: row.employeeId,
      deviceId: row.deviceId,
      action: AuditAction.values.firstWhere(
        (a) => a.value == row.action,
        orElse: () => AuditAction.update,
      ),
      entityType: row.entityType,
      entityId: row.entityId,
      oldValue: row.oldValue,
      newValue: row.newValue,
      metadata: jsonDecode(row.metadata) as Map<String, dynamic>,
      createdAt: row.createdAt,
      synced: row.synced,
    );
  }

  String _encode(Object value) {
    if (value is String) return value;
    return jsonEncode(value);
  }
}
