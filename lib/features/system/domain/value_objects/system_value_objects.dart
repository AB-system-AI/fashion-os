import 'package:equatable/equatable.dart';

/// Dashboard aggregate metrics for the system admin hub.
class SystemDashboardMetrics extends Equatable {
  const SystemDashboardMetrics({
    this.activeUsers = 0,
    this.pendingSyncItems = 0,
    this.openErrors = 0,
    this.healthStatus = 'unknown',
    this.maintenanceActive = false,
    this.storageUsedMb = 0,
    this.activeSessions = 0,
  });

  final int activeUsers;
  final int pendingSyncItems;
  final int openErrors;
  final String healthStatus;
  final bool maintenanceActive;
  final double storageUsedMb;
  final int activeSessions;

  @override
  List<Object?> get props => [
        activeUsers,
        pendingSyncItems,
        openErrors,
        healthStatus,
        maintenanceActive,
        storageUsedMb,
        activeSessions,
      ];
}

/// Filter criteria for audit explorer queries.
class AuditExplorerFilter extends Equatable {
  const AuditExplorerFilter({
    this.entityType,
    this.entityId,
    this.employeeId,
    this.action,
    this.from,
    this.to,
    this.page = 1,
    this.pageSize = 50,
  });

  final String? entityType;
  final String? entityId;
  final String? employeeId;
  final String? action;
  final DateTime? from;
  final DateTime? to;
  final int page;
  final int pageSize;

  @override
  List<Object?> get props => [entityType, entityId, employeeId, action, from, to, page, pageSize];
}

/// Diagnostics bundle returned by [DiagnosticsService].
class DiagnosticsReport extends Equatable {
  const DiagnosticsReport({
    required this.generatedAt,
    this.appVersion = '',
    this.flavor = '',
    this.databaseOk = true,
    this.syncState = 'idle',
    this.pendingQueue = 0,
    this.networkOnline = false,
    this.details = const {},
  });

  final DateTime generatedAt;
  final String appVersion;
  final String flavor;
  final bool databaseOk;
  final String syncState;
  final int pendingQueue;
  final bool networkOnline;
  final Map<String, dynamic> details;

  @override
  List<Object?> get props => [generatedAt, appVersion, databaseOk, syncState, pendingQueue];
}
