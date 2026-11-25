import '../cards/flashcard.dart';
import 'scheduling_calendar.dart';

/// Spreads the long intervals over the days around their due day, so that
/// the reviews do not pile up on a few days.
///
/// Rules owned here:
/// - an interval of 15 days or more may land 1 day before or after its due
///   day, 2 days from 30 days, 3 days from 90 days; a shorter one keeps it;
/// - a due day with no card due is kept; otherwise the card lands on the day
///   of that window with the fewest cards due, the due day winning a tie,
///   then the nearest day, then the earliest.
class DueSmoothing {
  const DueSmoothing(this.calendar, this._dueByDay);

  /// The scheduled [cards] counted on their due day, the card being
  /// rescheduled, [excluded], left out.
  factory DueSmoothing.of(
    Iterable<Flashcard> cards,
    SchedulingCalendar calendar, {
    required int excluded,
  }) {
    final dueByDay = <DateTime, int>{};
    for (final card in cards) {
      if (card.isScheduled && card.id != excluded) {
        dueByDay.update(
          calendar.dayOf(card.dueAt!),
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }
    return DueSmoothing(calendar, dueByDay);
  }

  final SchedulingCalendar calendar;
  final Map<DateTime, int> _dueByDay;

  /// The day a card due on [dueDay] after an interval of [intervalDays] lands
  /// on.
  DateTime dayFor(DateTime dueDay, {required int intervalDays}) {
    final reach = reachFor(intervalDays);
    if (reach == 0 || _dueOn(dueDay) == 0) {
      return dueDay;
    }
    // In the order of the tie: the first day with the fewest cards wins.
    final window = [
      dueDay,
      for (var offset = 1; offset <= reach; offset++) ...[
        calendar.addDays(dueDay, -offset),
        calendar.addDays(dueDay, offset),
      ],
    ];
    return window.reduce(
      (best, day) => _dueOn(day) < _dueOn(best) ? day : best,
    );
  }

  /// Days the due day may move by, before or after, for an interval of
  /// [intervalDays].
  static int reachFor(int intervalDays) => switch (intervalDays) {
    >= 90 => 3,
    >= 30 => 2,
    >= 15 => 1,
    _ => 0,
  };

  int _dueOn(DateTime day) => _dueByDay[day] ?? 0;
}
