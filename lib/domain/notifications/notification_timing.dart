import '../cards/flashcard.dart';
import '../scheduling/scheduling_calendar.dart';

/// When reminders are shown, and when the app must wake up to show them.
abstract final class NotificationTiming {
  /// Whether [card] must be notified now: it is scheduled, the moment
  /// [deliverAt] planned for its notification has come, however long ago,
  /// and it was not notified yet that day.
  static bool shouldNotify(
    Flashcard card, {
    required DateTime deliverAt,
    required DateTime now,
    required SchedulingCalendar calendar,
  }) =>
      card.isScheduled &&
      !wasNotified(card, deliverAt: deliverAt, calendar: calendar) &&
      !deliverAt.isAfter(now);

  /// Whether [card] was notified for its current due date on the day of
  /// [deliverAt]. A notification of an earlier day, ignored or swiped, does
  /// not count: the card is notified again.
  static bool wasNotified(
    Flashcard card, {
    required DateTime deliverAt,
    required SchedulingCalendar calendar,
  }) {
    final notifiedAt = card.notifiedAt;
    return notifiedAt != null &&
        !calendar.dayOf(notifiedAt).isBefore(calendar.dayOf(deliverAt));
  }

  /// The [limit] next distinct wake-up moments after [now], each [moment]
  /// rounded up to the minute so that one wake-up shows everything due
  /// within that minute.
  static List<DateTime> wakeUps(
    Iterable<DateTime> moments, {
    required DateTime now,
    required int limit,
  }) {
    final wakeUps = {
      for (final moment in moments)
        if (moment.isAfter(now)) _ceilToMinute(moment),
    }.toList()..sort();
    return wakeUps.take(limit).toList();
  }

  static DateTime _ceilToMinute(DateTime moment) {
    final minute = DateTime(
      moment.year,
      moment.month,
      moment.day,
      moment.hour,
      moment.minute,
    );
    return minute == moment ? minute : minute.add(const Duration(minutes: 1));
  }
}
