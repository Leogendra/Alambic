import '../../domain/cards/flashcard.dart';
import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_rhythm.dart';
import '../../domain/presets/preset_catalog.dart';
import '../../domain/reviews/extra_reminder.dart';
import '../../domain/scheduling/due_policy.dart';
import '../../domain/scheduling/scheduling_calendar.dart';
import 'home_timeline.dart';
import 'timeline_arrival.dart';
import 'timeline_card.dart';
import 'timeline_day.dart';

/// Builds Home's timeline over [dayCount] days: today with its late cards,
/// then the following days, card by card. New cards are never named: each
/// group gets one line with their count, made of the introduced cards never
/// answered and of those its distillation should introduce. Further on,
/// the reminders and new cards of the coming month and year are only
/// counted.
class TimelinePlanner {
  const TimelinePlanner({
    required this.calendar,
    required this.duePolicy,
    required this.rhythm,
  });

  static const int dayCount = 7;

  /// Days covered by the timeline and the coming month, from today.
  static const int monthDayCount = 30;

  /// Days covered by the timeline and the coming year, from today.
  static const int yearDayCount = 365;

  final SchedulingCalendar calendar;
  final DuePolicy duePolicy;
  final DistillationRhythm rhythm;

  HomeTimeline build({
    required List<Flashcard> cards,
    required List<ExtraReminder> reminders,
    required List<Distillation> distillations,
    required PresetCatalog catalog,
    required bool globallyPaused,
    required DateTime now,
  }) {
    final today = calendar.dayOf(now);
    final days = _DayBuckets(calendar, today);
    _placeCards(days, cards, now);
    _placeReminders(days, cards, reminders, now);
    if (!globallyPaused) {
      _placeDistillations(days, cards, distillations, catalog, now);
    }
    return HomeTimeline(
      days: [
        for (var offset = 0; offset < dayCount; offset++)
          if (days.dayAt(offset) case final day
              when offset == 0 || !day.isEmpty)
            day,
      ],
      comingMonth: days.comingMonth,
      comingYear: days.comingYear,
    );
  }

  /// A due card goes on today, late or not; another one on its due day.
  void _placeCards(_DayBuckets days, List<Flashcard> cards, DateTime now) {
    for (final card in cards) {
      final dueAt = card.dueAt;
      if (card.suspended || !card.isScheduled || dueAt == null) {
        continue;
      }
      final day = duePolicy.isDueToday(card, now: now)
          ? days.today
          : calendar.dayOf(dueAt);
      if (card.lastReviewedAt == null) {
        days.addArrivals(day, card.groupId, 1);
      } else {
        final isLate = calendar.dayOf(dueAt).isBefore(days.today);
        days.addCard(
          day,
          TimelineCard(
            card: card,
            at: dueAt,
            isLate: isLate,
            delay: isLate ? null : _delay(dueAt, now),
          ),
        );
      }
    }
  }

  void _placeReminders(
    _DayBuckets days,
    List<Flashcard> cards,
    List<ExtraReminder> reminders,
    DateTime now,
  ) {
    final cardsById = {for (final card in cards) card.id: card};
    for (final reminder in reminders) {
      final card = cardsById[reminder.cardId];
      if (card != null && !card.suspended) {
        days.addCard(
          calendar.dayOf(reminder.remindAt),
          TimelineCard(
            card: card,
            at: reminder.remindAt,
            isExtraReminder: true,
            delay: _delay(reminder.remindAt, now),
          ),
        );
      }
    }
  }

  /// Arrivals of the distillations not paused, the reviews of their group
  /// taking their places.
  void _placeDistillations(
    _DayBuckets days,
    List<Flashcard> cards,
    List<Distillation> distillations,
    PresetCatalog catalog,
    DateTime now,
  ) {
    for (final distillation in distillations) {
      final groupId = distillation.groupId;
      if (distillation.isPaused) {
        continue;
      }
      final arrivals = rhythm.forecast(
        distillation.settings,
        cards.where((card) => card.groupId == groupId),
        preset: catalog.presetForGroup(groupId),
        end: catalog.sequenceEndForGroup(groupId),
        firstDay: rhythm.nextIntroductionDay(distillation, days.today),
        now: now,
        until: days.end,
      );
      for (final arrival in arrivals.entries) {
        days.addArrivals(arrival.key, groupId, arrival.value);
      }
    }
  }

  /// Time left before a reminder at [at]: hours rounded up today, days
  /// afterwards; nothing once its moment has passed.
  TimelineDelay? _delay(DateTime at, DateTime now) {
    final days = calendar.daysBetween(now, at);
    if (days > 0) {
      return TimelineDelay.days(days);
    } else if (at.isAfter(now)) {
      return TimelineDelay.hours((at.difference(now).inSeconds + 3599) ~/ 3600);
    } else {
      return null;
    }
  }
}

/// The days of the timeline being filled, and the counts of the coming
/// month and year; anything after them is dropped.
class _DayBuckets {
  _DayBuckets(this._calendar, this.today)
    : _monthStart = _calendar.addDays(today, TimelinePlanner.dayCount),
      _yearStart = _calendar.addDays(today, TimelinePlanner.monthDayCount),
      end = _calendar.addDays(today, TimelinePlanner.yearDayCount);

  final SchedulingCalendar _calendar;
  final DateTime today;
  final DateTime _monthStart;
  final DateTime _yearStart;

  /// First day after the coming year.
  final DateTime end;
  final Map<DateTime, List<TimelineCard>> _cards = {};
  final Map<DateTime, Map<int, int>> _arrivals = {};
  int comingMonth = 0;
  int comingYear = 0;

  void addCard(DateTime day, TimelineCard card) {
    if (_covers(day)) {
      _cards.putIfAbsent(day, () => []).add(card);
    } else {
      _countLater(day, 1);
    }
  }

  void addArrivals(DateTime day, int groupId, int count) {
    if (_covers(day)) {
      final groups = _arrivals.putIfAbsent(day, () => {});
      groups[groupId] = (groups[groupId] ?? 0) + count;
    } else {
      _countLater(day, count);
    }
  }

  TimelineDay dayAt(int offset) {
    final day = _calendar.addDays(today, offset);
    return TimelineDay(
      day: day,
      isToday: offset == 0,
      cards: (_cards[day] ?? [])..sort(_lateFirstThenByMoment),
      arrivals: [
        for (final arrival in (_arrivals[day] ?? {}).entries)
          TimelineArrival(groupId: arrival.key, count: arrival.value),
      ],
    );
  }

  bool _covers(DateTime day) =>
      !day.isBefore(today) && day.isBefore(_monthStart);

  void _countLater(DateTime day, int count) {
    if (day.isBefore(_monthStart)) {
      return;
    } else if (day.isBefore(_yearStart)) {
      comingMonth += count;
    } else if (day.isBefore(end)) {
      comingYear += count;
    }
  }

  static int _lateFirstThenByMoment(TimelineCard first, TimelineCard second) {
    if (first.isLate != second.isLate) {
      return first.isLate ? -1 : 1;
    } else if (first.at != second.at) {
      return first.at.compareTo(second.at);
    } else {
      return first.card.id.compareTo(second.card.id);
    }
  }
}
