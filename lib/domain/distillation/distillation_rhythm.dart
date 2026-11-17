import 'dart:math';

import '../scheduling/scheduling_calendar.dart';
import 'distillation.dart';

/// "N cards every X days", day by day.
///
/// A batch comes out X days after the last one, counted from the day it came
/// out. It is never completed the next days, and a missed batch is not
/// caught up: at most one batch comes out per day, and the rhythm starts
/// again from that day.
class DistillationRhythm {
  const DistillationRhythm(this.calendar);

  final SchedulingCalendar calendar;

  /// Whether [distillation] owes a batch on [day]: none came out yet, or X
  /// days have passed since the last one.
  bool batchDue(Distillation distillation, DateTime day) {
    final lastBatchDay = distillation.lastBatchDay;
    return lastBatchDay == null ||
        !day.isBefore(calendar.addDays(lastBatchDay, distillation.everyDays));
  }

  /// New cards of a batch when [dueCards] cards of the group are due at the
  /// pass: with "Prioritize reviews", each of them takes the place of a new
  /// card.
  int newCards(Distillation distillation, {required int dueCards}) =>
      distillation.prioritizeReviews
      ? max(0, distillation.cardsPerBatch - dueCards)
      : distillation.cardsPerBatch;

  /// New cards [distillation] should introduce on each of the [dayCount]
  /// days from [today], when every batch goes through and [remaining] cards
  /// wait in its queue. Days without arrival are left out; today counts only
  /// while its pass has not run yet.
  Map<DateTime, int> arrivals(
    Distillation distillation, {
    required int remaining,
    required DateTime today,
    required int dayCount,
  }) {
    final arrivals = <DateTime, int>{};
    final end = calendar.addDays(today, dayCount);
    var day = nextIntroductionDay(distillation, today);
    var left = remaining;
    while (left > 0 && day.isBefore(end)) {
      final count = min(distillation.cardsPerBatch, left);
      arrivals[day] = count;
      left -= count;
      day = calendar.addDays(day, distillation.everyDays);
    }
    return arrivals;
  }

  /// Day on which the last of [remaining] cards arrives when every batch
  /// goes through, the first batch arriving on [firstDay]; `null` when
  /// nothing remains.
  DateTime? lastArrival({
    required int remaining,
    required int cardsPerBatch,
    required int everyDays,
    required DateTime firstDay,
  }) {
    if (remaining <= 0) {
      return null;
    } else {
      final batches = (remaining / cardsPerBatch).ceil();
      return calendar.addDays(firstDay, (batches - 1) * everyDays);
    }
  }

  /// Day on which [distillation] owes its next batch, seen from [today]: not
  /// before the next pass, nor before X days after the last batch.
  DateTime nextIntroductionDay(Distillation distillation, DateTime today) {
    final earliest = distillation.lastAdvancedDay == today
        ? calendar.addDays(today, 1)
        : today;
    final lastBatchDay = distillation.lastBatchDay;
    if (lastBatchDay == null) {
      return earliest;
    } else {
      final next = calendar.addDays(lastBatchDay, distillation.everyDays);
      return next.isAfter(earliest) ? next : earliest;
    }
  }
}
