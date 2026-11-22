import 'dart:math';

import '../cards/flashcard.dart';
import '../groups/sequence_end.dart';
import '../presets/preset.dart';
import '../scheduling/scheduling_calendar.dart';
import 'distillation.dart';
import 'distillation_queue.dart';
import 'distillation_settings.dart';
import 'review_load.dart';

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

  /// Days looked at by [forecast] when no [until] is given.
  static const int horizonDays = 730;

  /// New cards expected from the queue of a group with [settings], batch
  /// after batch from [firstDay] until it is empty, or until the day before
  /// [until] (two years from [now] by default): the cards left in the queue
  /// at that point are not in the result.
  ///
  /// Without "Prioritize reviews", every batch goes through. With it, the
  /// reviews of the group take the place of new cards, each card being
  /// supposed always answered "Correct" on its due day, as a [ReviewLoad]
  /// plays it with the [preset] and the [end] of the group: the cards
  /// already introduced follow it from their next due date, and each new
  /// card follows it from its arrival. Days without new card are left out;
  /// the days come in order.
  Map<DateTime, int> forecast(
    DistillationSettings settings,
    Iterable<Flashcard> groupCards, {
    required Preset preset,
    required SequenceEnd end,
    required DateTime firstDay,
    required DateTime now,
    DateTime? until,
  }) {
    final limit = until ?? calendar.addDays(calendar.dayOf(now), horizonDays);
    final load = settings.prioritizeReviews
        ? _loadOf(groupCards, preset, end, now, limit)
        : null;
    final arrivals = <DateTime, int>{};
    var left = DistillationQueue.remaining(groupCards);
    var day = firstDay;
    while (left > 0 && day.isBefore(limit)) {
      final count = min(newCards(settings, dueCards: load?.on(day) ?? 0), left);
      if (count > 0) {
        arrivals[day] = count;
        left -= count;
        load?.addNewCards(day, count);
      }
      day = calendar.addDays(day, 1);
    }
    return arrivals;
  }

  /// The reviews of the cards of [groupCards] already introduced.
  ReviewLoad _loadOf(
    Iterable<Flashcard> groupCards,
    Preset preset,
    SequenceEnd end,
    DateTime now,
    DateTime limit,
  ) {
    final load = ReviewLoad(
      calendar: calendar,
      preset: preset,
      end: end,
      until: limit,
    );
    for (final card in groupCards) {
      load.addIntroducedCard(card, now: now);
    }
    return load;
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
