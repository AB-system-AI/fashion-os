import 'package:equatable/equatable.dart';

import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';

/// Calendar event (holiday, closing, working hours).
class CalendarEvent extends Equatable {
  const CalendarEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.startAt,
    this.endAt,
    this.storeId,
    this.isRecurring = false,
    this.metadata = const {},
  });

  final String id;
  final CalendarEventType type;
  final String title;
  final DateTime startAt;
  final DateTime? endAt;
  final String? storeId;
  final bool isRecurring;
  final Map<String, dynamic> metadata;

  bool isActiveAt(DateTime at) {
    if (at.isBefore(startAt)) return false;
    if (endAt != null && at.isAfter(endAt!)) return false;
    return true;
  }

  @override
  List<Object?> get props => [id, type, startAt, storeId];
}

/// Store working hours for a day of week (1=Monday .. 7=Sunday).
class WorkingHours extends Equatable {
  const WorkingHours({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    this.isClosed = false,
  });

  final int dayOfWeek;
  final Duration openTime;
  final Duration closeTime;
  final bool isClosed;

  bool isOpenAt(DateTime at) {
    if (isClosed) return false;
    final day = at.weekday;
    if (day != dayOfWeek) return false;
    final timeOfDay = Duration(hours: at.hour, minutes: at.minute);
    return !timeOfDay.isNegative &&
        timeOfDay >= openTime &&
        timeOfDay <= closeTime;
  }

  @override
  List<Object?> get props => [dayOfWeek, openTime, closeTime];
}

/// Financial year configuration.
class FinancialYear extends Equatable {
  const FinancialYear({
    required this.startMonth,
    required this.startDay,
    this.label,
  });

  final int startMonth;
  final int startDay;
  final String? label;

  DateTime startOfYearFor(DateTime date) {
    var year = date.year;
    final candidate = DateTime(year, startMonth, startDay);
    if (date.isBefore(candidate)) year--;
    return DateTime(year, startMonth, startDay);
  }

  DateTime endOfYearFor(DateTime date) {
    final start = startOfYearFor(date);
    return DateTime(start.year + 1, startMonth, startDay).subtract(const Duration(days: 1));
  }

  @override
  List<Object?> get props => [startMonth, startDay];
}
