import '../cards/flashcard.dart';
import '../groups/sequence_end.dart';
import '../presets/preset.dart';
import '../presets/preset_interval.dart';
import '../reviews/review_outcome.dart';
import '../scheduling/card_progress.dart';
import '../scheduling/due_policy.dart';
import '../scheduling/scheduling_calendar.dart';
import '../scheduling/sequence_engine.dart';
import '../scheduling/sequence_step.dart';

/// Reviews of a group, day by day, if every card were always answered
/// "Correct" on its due day.
///
/// Each card walks its sequence, then its remanence, through the same
/// [SequenceEngine] as a real answer. A review counts on the day it falls;
/// an interval of less than a day brings the next review back the same day,
/// where it is not counted again. Nothing is counted from [until] on.
class ReviewLoad {
  ReviewLoad({
    required this.calendar,
    required this.preset,
    required this.end,
    required this.until,
  });

  final SchedulingCalendar calendar;
  final Preset preset;
  final SequenceEnd end;
  final DateTime until;

  final Map<DateTime, int> _byDay = {};

  /// Reviews falling on [day].
  int on(DateTime day) => _byDay[day] ?? 0;

  /// The reviews of a card already introduced, from its next due date: today
  /// when it is due at [now], late ones included. A card due later today
  /// does not count today, as at a pass; a suspended or acquired card has no
  /// review.
  void addIntroducedCard(Flashcard card, {required DateTime now}) {
    final dueAt = card.dueAt;
    if (card.suspended || !card.isScheduled || dueAt == null) {
      return;
    }
    final today = calendar.dayOf(now);
    final dueNow = DuePolicy(calendar).isDueToday(card, now: now);
    final firstDay = dueNow ? today : calendar.dayOf(dueAt);
    _walk(
      CardProgress.of(card, preset, end),
      firstDay,
      countFirst: dueNow || firstDay.isAfter(today),
      copies: 1,
    );
  }

  /// The reviews of [count] cards introduced on [day]: the introduction
  /// itself is not one, the cards are answered the same day.
  void addNewCards(DateTime day, int count) =>
      _walk(const NewProgress(), day, countFirst: false, copies: count);

  void _walk(
    CardProgress start,
    DateTime firstDay, {
    required bool countFirst,
    required int copies,
  }) {
    var progress = start;
    var day = firstDay;
    if (countFirst) {
      _count(day, copies);
    }
    while (day.isBefore(until)) {
      final reached = SequenceEngine.answer(
        progress: progress,
        outcome: ReviewOutcome.correct,
        preset: preset,
        end: end,
      );
      final PresetInterval interval;
      switch (reached) {
        case StepReached(:final step, interval: final stepInterval):
          interval = stepInterval;
          progress = SequenceProgress(
            step: step,
            sequenceLength: preset.sequenceLength,
            interval: stepInterval,
          );
        case RemanenceReached(interval: final remanenceInterval):
          // A remanence shorter than a day would come back forever the same
          // day.
          if (!remanenceInterval.isDayBased) {
            return;
          }
          interval = remanenceInterval;
          progress = RemanenceProgress(
            sequenceLength: preset.sequenceLength,
            interval: remanenceInterval,
          );
        case AcquiredReached():
          return;
      }
      if (interval.isDayBased) {
        day = calendar.addDays(day, interval.days);
        _count(day, copies);
      }
    }
  }

  void _count(DateTime day, int copies) {
    if (day.isBefore(until)) {
      _byDay[day] = (_byDay[day] ?? 0) + copies;
    }
  }
}
