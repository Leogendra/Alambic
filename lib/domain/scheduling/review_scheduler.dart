import '../cards/card_state.dart';
import '../cards/flashcard.dart';
import '../groups/sequence_end.dart';
import '../presets/preset.dart';
import '../presets/preset_interval.dart';
import '../reviews/review_outcome.dart';
import 'card_progress.dart';
import 'card_schedule.dart';
import 'clock_time.dart';
import 'due_smoothing.dart';
import 'scheduling_calendar.dart';
import 'sequence_engine.dart';
import 'sequence_step.dart';

/// Turns an answer into the next due date of a card.
///
/// Rules owned here:
/// - the sequence of the preset gives the interval of the step reached, and
///   the group the interval of the remanence;
/// - an interval of a day or more counts from the answer day and lands on the
///   daily slot of the app; a shorter one counts from the answer moment;
/// - with a [DueSmoothing], an answer may move a due day of 15 days or more
///   to a less busy day nearby; a step set by hand never moves.
class ReviewScheduler {
  const ReviewScheduler(this.calendar);

  final SchedulingCalendar calendar;

  /// [smoothing], when given, moves the due day of a long interval.
  CardSchedule afterAnswer({
    required Flashcard card,
    required ReviewOutcome outcome,
    required Preset preset,
    required SequenceEnd end,
    required DateTime answeredAt,
    required ClockTime dailySlot,
    DueSmoothing? smoothing,
  }) => _reached(
    SequenceEngine.answer(
      progress: CardProgress.of(card, preset, end),
      outcome: outcome,
      preset: preset,
      end: end,
    ),
    answeredAt,
    dailySlot,
    smoothing,
  );

  /// Schedule of a card that reaches [step] at the moment [from] because the
  /// user put it there: its interval counts from [from].
  CardSchedule atStep(
    SequenceStep step, {
    required DateTime from,
    required ClockTime dailySlot,
  }) => _reached(step, from, dailySlot, null);

  CardSchedule _reached(
    SequenceStep step,
    DateTime from,
    ClockTime dailySlot,
    DueSmoothing? smoothing,
  ) => switch (step) {
    StepReached(:final step, :final interval) => CardSchedule(
      state: CardState.active,
      step: step,
      dueAt: _dueAfter(interval, from, dailySlot, smoothing),
    ),
    RemanenceReached(:final interval) => CardSchedule(
      state: CardState.completed,
      step: null,
      dueAt: _dueAfter(interval, from, dailySlot, smoothing),
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
    final afterLastReview = _dueAfter(
      interval,
      lastReviewedAt,
      dailySlot,
      null,
    );
    final overdue = calendar
        .dayOf(afterLastReview)
        .isBefore(calendar.dayOf(now));
    return CardSchedule(
      state: CardState.completed,
      step: null,
      dueAt: overdue
          ? _dueAfter(interval, now, dailySlot, null)
          : afterLastReview,
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
    DueSmoothing? smoothing,
  ) {
    if (interval.isDayBased) {
      final dueDay = calendar.addDays(
        calendar.dayOf(answeredAt),
        interval.days,
      );
      return calendar.momentAt(
        smoothing?.dayFor(dueDay, intervalDays: interval.days) ?? dueDay,
        dailySlot,
      );
    } else {
      return answeredAt.add(interval.subDayDuration);
    }
  }
}
