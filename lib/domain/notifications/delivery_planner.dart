import '../cards/flashcard.dart';
import '../scheduling/clock_time.dart';
import '../scheduling/scheduling_calendar.dart';
import 'notification_guards.dart';
import 'notification_timing.dart';
import 'reminder_settings.dart';

/// Decides when each due card is notified, which is not always its due
/// date.
///
/// Rules owned here:
/// - a card still due from an earlier day (its notification was ignored,
///   swiped or not shown) is notified again today, at the daily slot;
/// - a notification not shown at its moment today (the phone was off, the
///   alarm held back) is shown now, whatever its delay;
/// - with a time range and one notification per card, the cards due at
///   the start of the range on a day are spread evenly over the range, in
///   the order of their ids; a grouped reminder stays at the start;
/// - a notification falling in the quiet hours is moved to their end.
class DeliveryPlanner {
  const DeliveryPlanner(this.calendar);

  final SchedulingCalendar calendar;

  /// Moment at which each scheduled card among [cards] is notified, by card
  /// id. A pause never removes a card from it.
  Map<int, DateTime> plan(
    Iterable<Flashcard> cards, {
    required DateTime now,
    required ReminderSettings reminders,
    NotificationGuards? guards,
  }) {
    final scheduled = {
      for (final card in cards)
        if (card.isScheduled) card.id: card,
    };
    return _moments(scheduled.values, now, reminders, guards)..updateAll(
      (id, moment) =>
          _outOfQuietHours(_late(scheduled[id]!, moment, now), guards),
    );
  }

  /// When a card whose notification moment has passed, still due, is notified
  /// again: at the daily slot of the next day. Nothing else may wake the app
  /// up by then, so this moment is planned too.
  DateTime nextDayRetry({
    required DateTime now,
    required ReminderSettings reminders,
    NotificationGuards? guards,
  }) => _outOfQuietHours(
    calendar.momentAt(
      calendar.addDays(calendar.dayOf(now), 1),
      reminders.dailySlot,
    ),
    guards,
  );

  /// Notification moments before the quiet hours.
  Map<int, DateTime> _moments(
    Iterable<Flashcard> cards,
    DateTime now,
    ReminderSettings reminders,
    NotificationGuards? guards,
  ) {
    final today = calendar.dayOf(now);
    final moments = <int, DateTime>{};
    final ranges = <DateTime, List<Flashcard>>{};
    for (final card in cards) {
      final dueAt = card.dueAt!;
      final missed = calendar
          .dayOf(_outOfQuietHours(dueAt, guards))
          .isBefore(today);
      final moment = missed
          ? calendar.momentAt(today, reminders.dailySlot)
          : dueAt;
      final day = calendar.dayOf(moment);
      if (reminders.spreadsOverRange &&
          moment == calendar.momentAt(day, reminders.rangeStart)) {
        ranges.putIfAbsent(day, () => []).add(card);
      } else {
        moments[card.id] = moment;
      }
    }
    for (final MapEntry(key: day, value: sharing) in ranges.entries) {
      moments.addAll(_spread(sharing, day, reminders));
    }
    return moments;
  }

  /// [sharing] spread over the range on [day]: the first at its start, then
  /// one every range length divided by their number.
  Map<int, DateTime> _spread(
    List<Flashcard> sharing,
    DateTime day,
    ReminderSettings reminders,
  ) {
    final start = calendar.momentAt(day, reminders.rangeStart);
    final end = calendar.momentAt(day, reminders.rangeEnd);
    final range = end.isAfter(start) ? end.difference(start) : Duration.zero;
    final ordered = sharing.toList()
      ..sort((first, second) => first.id.compareTo(second.id));
    return {
      for (final (index, card) in ordered.indexed)
        card.id: _toMinute(start.add(range * index ~/ ordered.length)),
    };
  }

  /// [now] for a notification of [card] not shown at its [moment], already
  /// passed, so that a late notification falling in the quiet hours waits
  /// for their end like any other.
  DateTime _late(Flashcard card, DateTime moment, DateTime now) =>
      moment.isBefore(now) &&
          !NotificationTiming.wasNotified(
            card,
            deliverAt: moment,
            calendar: calendar,
          )
      ? now
      : moment;

  /// [moment], or the end of the quiet hours when it falls inside them.
  DateTime _outOfQuietHours(DateTime moment, NotificationGuards? guards) {
    if (guards == null ||
        !guards.isQuiet(ClockTime(moment.hour, moment.minute))) {
      return moment;
    }
    final end = guards.quietEnd;
    final sameDate = DateTime(moment.year, moment.month, moment.day);
    final endsToday = ClockTime(moment.hour, moment.minute).compareTo(end) < 0;
    final date = endsToday ? sameDate : calendar.addDays(sameDate, 1);
    return DateTime(date.year, date.month, date.day, end.hour, end.minute);
  }

  static DateTime _toMinute(DateTime moment) => DateTime(
    moment.year,
    moment.month,
    moment.day,
    moment.hour,
    moment.minute,
  );
}
