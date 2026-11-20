import '../cards/card_state.dart';
import '../cards/flashcard.dart';
import '../groups/sequence_end.dart';
import '../presets/preset.dart';
import '../presets/preset_interval.dart';
import '../reviews/review_outcome.dart';
import 'card_progress.dart';
import 'card_schedule.dart';
import 'clock_time.dart';
import 'scheduling_calendar.dart';
import 'sequence_engine.dart';
import 'sequence_step.dart';

/// Turns an answer into the next due date of a card.
///
/// Rules owned here:
/// - the sequence of the preset gives the interval of the step reached, and
///   the group the interval of the remanence;
/// - an interval of a day or more counts from the answer day and lands on the
///   daily slot of the app; a shorter one counts from the answer moment.
class ReviewScheduler {
  const ReviewScheduler(this.calendar);

  final SchedulingCalendar calendar;

  CardSchedule afterAnswer({
    required Flashcard card,
    required ReviewOutcome outcome,
    required Preset preset,
    required SequenceEnd end,
    required DateTime answeredAt,
    required ClockTime dailySlot,
  }) => switch (SequenceEngine.answer(
    progress: CardProgress.of(card, preset, end),
    outcome: outcome,
    preset: preset,
    end: end,
  )) {
    StepReached(:final step, :final interval) => CardSchedule(
      state: CardState.active,
      step: step,
      dueAt: _dueAfter(interval, answeredAt, dailySlot),
    ),
    RemanenceReached(:final interval) => CardSchedule(
      state: CardState.completed,
      step: null,
      dueAt: _dueAfter(interval, answeredAt, dailySlot),
    ),
    AcquiredReached() => CardSchedule.acquired,
  };

  /// Schedule of an acquired card whose group switches back to remanence:
  /// due one remanence interval after its last review. When that day has
  /// already passed, one remanence interval after [now] instead, so that the
  /// cards acquired long ago do not all become due at once.
  CardSchedule backToRemanence({
    required DateTime lastReviewedAt,
    required Preset preset,
    required SequenceEnd end,
    required DateTime now,
    required ClockTime dailySlot,
  }) {
    final interval = end.remanenceAfter(preset);
    final afterLastReview = _dueAfter(interval, lastReviewedAt, dailySlot);
    final overdue = calendar
        .dayOf(afterLastReview)
        .isBefore(calendar.dayOf(now));
    return CardSchedule(
      state: CardState.completed,
      step: null,
      dueAt: overdue ? _dueAfter(interval, now, dailySlot) : afterLastReview,
    );
  }

  /// Schedule of a card introduced by its distillation: due today at the
  /// daily slot, so it is due right away even when the slot has already
  /// passed.
  CardSchedule introduction({
    required ClockTime dailySlot,
    required DateTime now,
  }) => CardSchedule(
    state: CardState.active,
    step: null,
    dueAt: calendar.momentAt(calendar.dayOf(now), dailySlot),
  );

  DateTime _dueAfter(
    PresetInterval interval,
    DateTime answeredAt,
    ClockTime dailySlot,
  ) {
    if (interval.isDayBased) {
      final dueDay = calendar.addDays(
        calendar.dayOf(answeredAt),
        interval.days,
      );
      return calendar.momentAt(dueDay, dailySlot);
    } else {
      return answeredAt.add(interval.subDayDuration);
    }
  }
}
