import '../presets/notification_mode.dart';
import '../presets/schedule_kind.dart';
import '../scheduling/clock_time.dart';
import '../scheduling/card_progress.dart';
import '../scheduling/scheduling_calendar.dart';
import 'delivery_candidate.dart';
import 'notification_guards.dart';
import 'notification_timing.dart';

/// Decides when each due card is notified, which is not always its due
/// date.
///
/// Rules owned here:
/// - a card still due from an earlier day (its notification was ignored,
///   swiped or not shown) is notified again today, at the slot of its preset;
/// - with a time range and one notification per card, the cards due at
///   the start of the range on a day are spread evenly over the range, in
///   the order of their ids; a grouped reminder stays at the start;
/// - a notification falling in the quiet hours is moved to their end;
/// - beyond the daily cap, the cards waiting the longest intervals are
///   not notified that day: they are moved to the slot of the next day.
class DeliveryPlanner {
  const DeliveryPlanner(this.calendar);

  final SchedulingCalendar calendar;

  /// Moment at which each candidate is notified, by card id.
  /// [notifiedToday] counts the cards already notified today, which take
  /// their share of the daily cap.
  Map<int, DateTime> plan(
    Iterable<DeliveryCandidate> candidates, {
    required DateTime now,
    NotificationGuards? guards,
    int notifiedToday = 0,
  }) {
    final moments = _moments(candidates, now, guards)
      ..updateAll((_, moment) => _outOfQuietHours(moment, guards));
    if (guards != null) {
      _applyDailyCap(moments, candidates, now, guards, notifiedToday);
    }
    return moments;
  }

  /// When a card whose notification moment has passed, still due, is notified
  /// again: at the slot of its preset the next day. Nothing else may wake the
  /// app up by then, so this moment is planned too.
  DateTime nextDayRetry(
    DeliveryCandidate candidate, {
    required DateTime now,
    NotificationGuards? guards,
  }) => _outOfQuietHours(
    calendar.momentAt(
      calendar.addDays(calendar.dayOf(now), 1),
      candidate.preset.dailySlot,
    ),
    guards,
  );

  /// Notification moments before the quiet hours and the cap.
  Map<int, DateTime> _moments(
    Iterable<DeliveryCandidate> candidates,
    DateTime now,
    NotificationGuards? guards,
  ) {
    final today = calendar.dayOf(now);
    final moments = <int, DateTime>{};
    final ranges = <(int, DateTime), List<DeliveryCandidate>>{};
    for (final candidate in candidates) {
      final dueAt = candidate.card.dueAt!;
      final missed = calendar
          .dayOf(_outOfQuietHours(dueAt, guards))
          .isBefore(today);
      final moment = missed
          ? calendar.momentAt(today, candidate.preset.dailySlot)
          : dueAt;
      final day = calendar.dayOf(moment);
      if (_spreadsOverRange(candidate) &&
          moment == calendar.momentAt(day, candidate.preset.rangeStart)) {
        ranges.putIfAbsent((candidate.preset.id, day), () => []).add(candidate);
      } else {
        moments[candidate.card.id] = moment;
      }
    }
    for (final MapEntry(key: (_, day), value: sharing) in ranges.entries) {
      moments.addAll(_spread(sharing, day));
    }
    return moments;
  }

  static bool _spreadsOverRange(DeliveryCandidate candidate) =>
      candidate.preset.scheduleKind == ScheduleKind.timeRange &&
      candidate.preset.notificationMode == NotificationMode.perCard;

  /// [sharing] spread over the range of their preset on [day]: the first at
  /// its start, then one every range length divided by their number.
  Map<int, DateTime> _spread(List<DeliveryCandidate> sharing, DateTime day) {
    final preset = sharing.first.preset;
    final start = calendar.momentAt(day, preset.rangeStart);
    final end = calendar.momentAt(day, preset.rangeEnd);
    final range = end.isAfter(start) ? end.difference(start) : Duration.zero;
    final ordered = sharing.toList()
      ..sort((first, second) => first.card.id.compareTo(second.card.id));
    return {
      for (final (index, candidate) in ordered.indexed)
        candidate.card.id: _toMinute(
          start.add(range * index ~/ ordered.length),
        ),
    };
  }

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

  /// Moves in [moments], day by day, the candidates beyond the daily cap that
  /// were not notified yet to the slot of the next day: the longest interval
  /// waited goes last. The next day's cap is checked again on that day.
  void _applyDailyCap(
    Map<int, DateTime> moments,
    Iterable<DeliveryCandidate> candidates,
    DateTime now,
    NotificationGuards guards,
    int notifiedToday,
  ) {
    final today = calendar.dayOf(now);
    final waitingByDay = <DateTime, List<DeliveryCandidate>>{};
    for (final candidate in candidates) {
      final moment = moments[candidate.card.id]!;
      if (!NotificationTiming.wasNotified(
        candidate.card,
        deliverAt: moment,
        calendar: calendar,
      )) {
        waitingByDay
            .putIfAbsent(calendar.dayOf(moment), () => [])
            .add(candidate);
      }
    }
    for (final MapEntry(key: day, value: waiting) in waitingByDay.entries) {
      final room = guards.dailyCap - (day == today ? notifiedToday : 0);
      waiting.sort((first, second) => _byPriority(first, second, moments));
      for (final heldBack in waiting.skip(room < 0 ? 0 : room)) {
        moments[heldBack.card.id] = _outOfQuietHours(
          calendar.momentAt(
            calendar.addDays(day, 1),
            heldBack.preset.dailySlot,
          ),
          guards,
        );
      }
    }
  }

  /// The shortest interval waited first, then the earliest moment.
  static int _byPriority(
    DeliveryCandidate first,
    DeliveryCandidate second,
    Map<int, DateTime> moments,
  ) {
    final byInterval = CardProgress.of(first.card, first.preset).waitedInterval
        .compareTo(CardProgress.of(second.card, second.preset).waitedInterval);
    if (byInterval != 0) {
      return byInterval;
    }
    final byMoment = moments[first.card.id]!.compareTo(
      moments[second.card.id]!,
    );
    return byMoment != 0 ? byMoment : first.card.id.compareTo(second.card.id);
  }

  static DateTime _toMinute(DateTime moment) => DateTime(
    moment.year,
    moment.month,
    moment.day,
    moment.hour,
    moment.minute,
  );
}
