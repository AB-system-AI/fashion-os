import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';
import 'package:fashion_pos_enterprise/core/business/domain/value_objects/money.dart';

/// Cash drawer session state.
class CashSession extends Equatable {
  const CashSession({
    required this.id,
    required this.storeId,
    required this.registerId,
    required this.employeeId,
    required this.openingFloat,
    required this.openedAt,
    this.closingFloat,
    this.expectedCash,
    this.actualCash,
    this.totalSales = Money.fromMajor(0),
    this.totalRefunds = Money.fromMajor(0),
    this.transactionCount = 0,
    this.isOpen = true,
    this.closedAt,
  });

  final String id;
  final String storeId;
  final String registerId;
  final String employeeId;
  final Money openingFloat;
  final DateTime openedAt;
  final Money? closingFloat;
  final Money? expectedCash;
  final Money? actualCash;
  final Money totalSales;
  final Money totalRefunds;
  final int transactionCount;
  final bool isOpen;
  final DateTime? closedAt;

  Money get cashDifference {
    if (expectedCash == null || actualCash == null) return Money.fromMajor(0);
    return actualCash! - expectedCash!;
  }

  CashSession copyWith({
    Money? totalSales,
    Money? totalRefunds,
    int? transactionCount,
    Money? expectedCash,
    Money? actualCash,
    Money? closingFloat,
    bool? isOpen,
    DateTime? closedAt,
  }) {
    return CashSession(
      id: id,
      storeId: storeId,
      registerId: registerId,
      employeeId: employeeId,
      openingFloat: openingFloat,
      openedAt: openedAt,
      closingFloat: closingFloat ?? this.closingFloat,
      expectedCash: expectedCash ?? this.expectedCash,
      actualCash: actualCash ?? this.actualCash,
      totalSales: totalSales ?? this.totalSales,
      totalRefunds: totalRefunds ?? this.totalRefunds,
      transactionCount: transactionCount ?? this.transactionCount,
      isOpen: isOpen ?? this.isOpen,
      closedAt: closedAt ?? this.closedAt,
    );
  }

  @override
  List<Object?> get props => [id, storeId, registerId, isOpen];
}

/// Cash movement within a session.
class CashMovement extends Equatable {
  const CashMovement({
    required this.id,
    required this.sessionId,
    required this.type,
    required this.amount,
    required this.occurredAt,
    this.referenceType,
    this.referenceId,
    this.notes,
  });

  final String id;
  final String sessionId;
  final CashMovementType type;
  final Money amount;
  final DateTime occurredAt;
  final String? referenceType;
  final String? referenceId;
  final String? notes;

  @override
  List<Object?> get props => [id, sessionId, type, amount];
}
