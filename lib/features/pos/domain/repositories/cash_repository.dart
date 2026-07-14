import 'package:fashion_pos_enterprise/core/infrastructure/repository/base_local_repository.dart';
import 'package:fashion_pos_enterprise/core/infrastructure/repository/repository_query.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/cash_movement.dart';
import 'package:fashion_pos_enterprise/features/pos/domain/entities/cash_session.dart';

abstract class CashRepository implements BaseLocalRepository<CashSession> {
  Future<CashSession?> findOpenSession(String tenantId, String registerId);
  Future<List<CashMovement>> listMovements(String tenantId, String sessionId);
  Future<CashMovement> createMovement(CashMovement movement);
}
