import 'package:fashion_pos_enterprise/core/business/domain/entities/cash_session_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';
import 'package:fashion_pos_enterprise/core/result/result.dart';
import 'package:fashion_pos_enterprise/core/errors/failure.dart';

/// Manages cash drawer sessions, movements, and reconciliation.
class CashSessionEngine {
  Result<CashSession> openSession({
    required String sessionId,
    required String storeId,
    required String registerId,
    required String employeeId,
    required Money openingFloat,
    DateTime? openedAt,
  }) {
    if (openingFloat.isNegative) {
      return const Error(ValidationFailure(message: 'Opening float cannot be negative', code: 'invalid_cash'));
    }
    return Success(
      CashSession(
        id: sessionId,
        storeId: storeId,
        registerId: registerId,
        employeeId: employeeId,
        openingFloat: openingFloat,
        openedAt: openedAt ?? DateTime.now().toUtc(),
      ),
    );
  }

  Result<CashSession> recordSale(CashSession session, Money saleAmount) {
    if (!session.isOpen) {
      return const Error(ValidationFailure(message: 'Cash session is closed', code: 'session_closed'));
    }
    return Success(
      session.copyWith(
        totalSales: session.totalSales + saleAmount,
        transactionCount: session.transactionCount + 1,
        expectedCash: (session.expectedCash ?? session.openingFloat) + saleAmount,
      ),
    );
  }

  Result<CashSession> recordRefund(CashSession session, Money refundAmount) {
    if (!session.isOpen) {
      return const Error(ValidationFailure(message: 'Cash session is closed', code: 'session_closed'));
    }
    return Success(
      session.copyWith(
        totalRefunds: session.totalRefunds + refundAmount,
        expectedCash: (session.expectedCash ?? session.openingFloat) - refundAmount,
      ),
    );
  }

  Result<CashMovement> recordMovement({
    required String movementId,
    required CashSession session,
    required CashMovementType type,
    required Money amount,
    String? referenceType,
    String? referenceId,
    String? notes,
  }) {
    if (!session.isOpen) {
      return const Error(ValidationFailure(message: 'Cash session is closed', code: 'session_closed'));
    }
    return Success(
      CashMovement(
        id: movementId,
        sessionId: session.id,
        type: type,
        amount: amount,
        occurredAt: DateTime.now().toUtc(),
        referenceType: referenceType,
        referenceId: referenceId,
        notes: notes,
      ),
    );
  }

  Result<CashSession> closeSession({
    required CashSession session,
    required Money actualCash,
    Money? closingFloat,
  }) {
    if (!session.isOpen) {
      return const Error(ValidationFailure(message: 'Cash session is already closed', code: 'session_closed'));
    }
    final expected = session.expectedCash ?? session.openingFloat;
    return Success(
      session.copyWith(
        actualCash: actualCash,
        closingFloat: closingFloat,
        expectedCash: expected,
        isOpen: false,
        closedAt: DateTime.now().toUtc(),
      ),
    );
  }
}
