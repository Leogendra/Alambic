import 'dart:math';

import '../cards/flashcard.dart';
import '../scheduling/due_policy.dart';
import '../scheduling/scheduling_calendar.dart';
import 'distillation.dart';
import 'distillation_queue.dart';
import 'distillation_settings.dart';

/// "N cards a day", day by day.
///
/// A batch comes out the day after the last one. It is never completed the
/// next days, and a missed batch is not caught up: at most one batch comes
/// out per day.
class DistillationRhythm {
  const DistillationRhythm(this.calendar);

  final SchedulingCalendar calendar;

  /// Whether [distillation] owes a batch on [day]: none came out yet, or
  /// the last one came out before [day].
  bool batchDue(Distillation distillation, DateTime day) {
    final lastBatchDay = distillation.lastBatchDay;
    return lastBatchDay == null || lastBatchDay.isBefore(day);
  }

  /// New cards of a batch when [dueCards] cards of the group are due at the
  /// pass: with "Prioritize reviews", each of them takes the place of a new
  /// card.
  int newCards(DistillationSettings settings, {required int dueCards}) =>
      settings.prioritizeReviews
      ? max(0, settings.cardsPerBatch - dueCards)
      : settings.cardsPerBatch;

  /// New cards expected from the queue of a group with [settings], batch
  /// after batch from [firstDay] until it is empty, or until the day before
  /// [until]. Every batch goes through; with "Prioritize reviews", the
  /// reviews already planned on a batch day take the place of new cards.
  /// The reviews of the cards not introduced yet are unknown, so an
  /// arrival may slip. Days without new card are left out; the days come in
  /// order.
  Map<DateTime, int> forecast(
    DistillationSettings settings,
    Iterable<Flashcard> groupCards, {
    required DateTime firstDay,
    required DateTime now,
    DateTime? until,
  }) {
    final plannedReviews = _plannedReviews(groupCards, now);
    final arrivals = <DateTime, int>{};
    var left = DistillationQueue.remaining(groupCards);
    var day = firstDay;
    while (left > 0 && (until == null || day.isBefore(until))) {
      final count = min(
        newCards(settings, dueCards: plannedReviews[day] ?? 0),
        left,
      );
      if (count > 0) {
        arrivals[day] = count;
        left -= count;
      }
      day = calendar.addDays(day, 1);
    }
    return arrivals;
  }

  /// Reviews planned for each day among [groupCards], as a pass on that day
  /// would count them: today the cards due at [now], late ones included;
  /// later, the cards whose due day it is.
  Map<DateTime, int> _plannedReviews(
    Iterable<Flashcard> groupCards,
    DateTime now,
  ) {
    final duePolicy = DuePolicy(calendar);
    final today = calendar.dayOf(now);
    final reviews = <DateTime, int>{};
    for (final card in groupCards) {
      final dueAt = card.dueAt;
      if (duePolicy.isDueToday(card, now: now)) {
        reviews[today] = (reviews[today] ?? 0) + 1;
      } else if (!card.suspended &&
          card.isScheduled &&
          dueAt != null &&
          calendar.dayOf(dueAt).isAfter(today)) {
        final day = calendar.dayOf(dueAt);
        reviews[day] = (reviews[day] ?? 0) + 1;
      }
    }
    return reviews;
  }

  /// Day on which [distillation] owes its next batch, seen from [today]: not
  /// before the next pass, nor before the day after the last batch.
  DateTime nextIntroductionDay(Distillation distillation, DateTime today) {
    final earliest = distillation.lastAdvancedDay == today
        ? calendar.addDays(today, 1)
        : today;
    final lastBatchDay = distillation.lastBatchDay;
    if (lastBatchDay == null) {
      return earliest;
    } else {
      final next = calendar.addDays(lastBatchDay, 1);
      return next.isAfter(earliest) ? next : earliest;
    }
  }
}
