import '../../domain/cards/flashcard.dart';
import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_queue.dart';
import '../../domain/distillation/distillation_rhythm.dart';
import '../../domain/pauses/pauses.dart';
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
/// answered and of those its distillation should introduce, every batch
/// going through.
class TimelinePlanner {
  const TimelinePlanner({
    required this.calendar,
    required this.duePolicy,
    required this.rhythm,
  });

  static const int dayCount = 7;

  final SchedulingCalendar calendar;
  final DuePolicy duePolicy;
  final DistillationRhythm rhythm;

  HomeTimeline build({
    required List<Flashcard> cards,
    required List<ExtraReminder> reminders,
    required List<Distillation> distillations,
    required Pauses pauses,
    required DateTime now,
  }) {
    final today = calendar.dayOf(now);
    final days = _DayBuckets(calendar, today);
    _placeCards(days, cards, now);
    _placeReminders(days, cards, reminders);
    _placeDistillations(days, cards, distillations, pauses);
    return HomeTimeline([
      for (var offset = 0; offset < dayCount; offset++)
        if (days.dayAt(offset) case final day when offset == 0 || !day.isEmpty)
          day,
    ]);
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
        days.addCard(
          day,
          TimelineCard(
            card: card,
            at: dueAt,
            isLate: calendar.dayOf(dueAt).isBefore(days.today),
          ),
        );
      }
    }
  }

  void _placeReminders(
    _DayBuckets days,
    List<Flashcard> cards,
    List<ExtraReminder> reminders,
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
          ),
        );
      }
    }
  }

  /// Arrivals of the running distillations whose group is not paused.
  void _placeDistillations(
    _DayBuckets days,
    List<Flashcard> cards,
    List<Distillation> distillations,
    Pauses pauses,
  ) {
    for (final distillation in distillations) {
      final groupId = distillation.groupId;
      if (!distillation.isRunning || pauses.covers(groupId)) {
        continue;
      }
      final arrivals = rhythm.arrivals(
        distillation,
        remaining: DistillationQueue.remaining(
          cards.where((card) => card.groupId == groupId),
        ),
        today: days.today,
        dayCount: dayCount,
      );
      for (final arrival in arrivals.entries) {
        days.addArrivals(arrival.key, groupId, arrival.value);
      }
    }
  }
}

/// The days of the timeline being filled; anything outside them is dropped.
class _DayBuckets {
  _DayBuckets(this._calendar, this.today);

  final SchedulingCalendar _calendar;
  final DateTime today;
  final Map<DateTime, List<TimelineCard>> _cards = {};
  final Map<DateTime, Map<int, int>> _arrivals = {};

  void addCard(DateTime day, TimelineCard card) {
    if (_covers(day)) {
      _cards.putIfAbsent(day, () => []).add(card);
    }
  }

  void addArrivals(DateTime day, int groupId, int count) {
    if (_covers(day)) {
      final groups = _arrivals.putIfAbsent(day, () => {});
      groups[groupId] = (groups[groupId] ?? 0) + count;
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
      !day.isBefore(today) &&
      day.isBefore(_calendar.addDays(today, TimelinePlanner.dayCount));

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
