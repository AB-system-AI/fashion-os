import 'package:fashion_pos_enterprise/core/business/domain/entities/calendar_models.dart';
import 'package:fashion_pos_enterprise/core/business/domain/enums/business_enums.dart';

/// Business calendar for working hours, holidays, and financial periods.
class BusinessCalendarEngine {
  BusinessCalendarEngine({
    List<WorkingHours> workingHours = const [],
    List<CalendarEvent> events = const [],
    FinancialYear? financialYear,
  })  : _workingHours = workingHours,
        _events = events,
        _financialYear = financialYear ?? const FinancialYear(startMonth: 1, startDay: 1);

  final List<WorkingHours> _workingHours;
  final List<CalendarEvent> _events;
  final FinancialYear _financialYear;

  void addWorkingHours(WorkingHours hours) => _workingHours.add(hours);
  void addEvent(CalendarEvent event) => _events.add(event);

  bool isStoreOpen(DateTime at, {String? storeId}) {
    if (_isHoliday(at, storeId: storeId)) return false;
    if (_workingHours.isEmpty) return true;
    return _workingHours.any((h) => h.isOpenAt(at));
  }

  bool _isHoliday(DateTime at, {String? storeId}) {
    return _events.any((e) {
      if (e.type != CalendarEventType.holiday) return false;
      if (storeId != null && e.storeId != null && e.storeId != storeId) return false;
      return e.isActiveAt(at);
    });
  }

  bool isDailyClosingDue(DateTime at) {
    return _events.any((e) => e.type == CalendarEventType.dailyClosing && e.isActiveAt(at));
  }

  bool isMonthlyClosingDue(DateTime at) {
    return _events.any((e) => e.type == CalendarEventType.monthlyClosing && e.isActiveAt(at));
  }

  DateTime financialYearStart(DateTime at) => _financialYear.startOfYearFor(at);
  DateTime financialYearEnd(DateTime at) => _financialYear.endOfYearFor(at);

  List<CalendarEvent> upcomingEvents({String? storeId, int limit = 10}) {
    final now = DateTime.now().toUtc();
    final filtered = _events.where((e) {
      if (e.startAt.isBefore(now)) return false;
      if (storeId != null && e.storeId != null && e.storeId != storeId) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
    return filtered.take(limit).toList();
  }
}
