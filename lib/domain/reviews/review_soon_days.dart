import '../scheduling/scheduling_calendar.dart';

/// The days offered by "Review soon", computed from today.
class ReviewSoonDays {
  ReviewSoonDays({required SchedulingCalendar calendar, required DateTime now})
    : tomorrow = calendar.addDays(calendar.dayOf(now), 1),
      dayAfterTomorrow = calendar.addDays(calendar.dayOf(now), 2),
      weekend = _nextWeekendDay(calendar, calendar.dayOf(now));

  final DateTime tomorrow;
  final DateTime dayAfterTomorrow;

  /// The coming Saturday; on a Saturday, the Sunday that follows.
  final DateTime weekend;

  static DateTime _nextWeekendDay(SchedulingCalendar calendar, DateTime today) {
    if (today.weekday == DateTime.saturday) {
      return calendar.addDays(today, 1);
    } else {
      return calendar.addDays(today, (DateTime.saturday - today.weekday) % 7);
    }
  }
}
