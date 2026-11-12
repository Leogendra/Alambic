import 'clock_time.dart';

/// Calendar behind every "same day" decision of the app.
///
/// A scheduling day starts at [dayStartHour] (4am) rather than midnight, so a
/// review done at 1am still counts for the previous evening. Days are
/// represented by their calendar date at local midnight.
class SchedulingCalendar {
  const SchedulingCalendar({this.dayStartHour = 4});

  final int dayStartHour;

  /// The scheduling day containing [moment].
  DateTime dayOf(DateTime moment) {
    final calendarDate = DateTime(moment.year, moment.month, moment.day);
    if (moment.hour < dayStartHour) {
      return addDays(calendarDate, -1);
    } else {
      return calendarDate;
    }
  }

  /// First moment of [day].
  DateTime startOf(DateTime day) =>
      DateTime(day.year, day.month, day.day, dayStartHour);

  /// First moment of the day after [day].
  DateTime endOf(DateTime day) => startOf(addDays(day, 1));

  /// [day] shifted by [days] calendar days, robust to daylight saving changes.
  DateTime addDays(DateTime day, int days) =>
      DateTime(day.year, day.month, day.day + days);

  /// Scheduling days from the day of [from] to the day of [to].
  int daysBetween(DateTime from, DateTime to) =>
      (dayOf(to).difference(dayOf(from)).inHours / 24).round();

  bool isSameDay(DateTime first, DateTime second) =>
      dayOf(first) == dayOf(second);

  /// The moment at which [time] falls inside [day].
  ///
  /// A time earlier than the day start (for example 2am) belongs to the end of
  /// the scheduling day, hence to the next calendar date.
  DateTime momentAt(DateTime day, ClockTime time) {
    final calendarDate = time.hour < dayStartHour ? addDays(day, 1) : day;
    return DateTime(
      calendarDate.year,
      calendarDate.month,
      calendarDate.day,
      time.hour,
      time.minute,
    );
  }
}
