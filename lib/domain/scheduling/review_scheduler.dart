import '../cards/card_direction.dart';
import '../cards/direction_state.dart';
import '../presets/interval_unit.dart';
import '../presets/preset.dart';
import '../presets/preset_interval.dart';
import '../presets/scheduling_engine_kind.dart';
import '../reviews/review_outcome.dart';
import 'direction_schedule.dart';
import 'fsrs/fsrs_engine.dart';
import 'fsrs/fsrs_rating.dart';
import 'scheduling_calendar.dart';
import 'sequence_engine.dart';

/// Turns an answer into the next due date of a direction.
///
/// Rules owned here:
/// - the engine of the preset gives the interval: the next step of the
///   sequence, or the FSRS interval for the target retention;
/// - an interval of a day or more counts from the answer day and lands on the
///   preset slot; a shorter one counts from the answer moment;
/// - the two directions of a card are never due the same day: on a clash the
///   direction being scheduled moves to the next day.
class ReviewScheduler {
  const ReviewScheduler(this.calendar);

  final SchedulingCalendar calendar;

  DirectionSchedule afterAnswer({
    required CardDirection direction,
    required ReviewOutcome outcome,
    required Preset preset,
    required DateTime answeredAt,
    required DateTime? oppositeDueAt,
  }) => switch (preset.engine) {
    SchedulingEngineKind.sequence => _afterSequenceAnswer(
      direction,
      outcome,
      preset,
      answeredAt,
      oppositeDueAt,
    ),
    SchedulingEngineKind.adaptive => _afterAdaptiveAnswer(
      direction,
      outcome,
      preset,
      answeredAt,
      oppositeDueAt,
    ),
  };

  /// Schedule of a direction entering review: due today at the preset slot,
  /// so it is due right away even when the slot has already passed.
  DirectionSchedule startSchedule({
    required Preset preset,
    required DateTime now,
    required DateTime? oppositeDueAt,
  }) {
    final todaySlot = calendar.momentAt(calendar.dayOf(now), preset.dailySlot);
    return DirectionSchedule(
      state: DirectionState.active,
      step: null,
      dueAt: _spacedFromOpposite(todaySlot, preset, oppositeDueAt),
    );
  }

  /// Schedule of a reminder held back by a distillation budget: the same
  /// progression, due the next day at the preset slot.
  DirectionSchedule postponed({
    required CardDirection direction,
    required Preset preset,
    required DateTime now,
    required DateTime? oppositeDueAt,
  }) {
    final nextDay = calendar.addDays(calendar.dayOf(now), 1);
    return DirectionSchedule(
      state: DirectionState.active,
      step: direction.step,
      memory: direction.memory,
      dueAt: _spacedFromOpposite(
        calendar.momentAt(nextDay, preset.dailySlot),
        preset,
        oppositeDueAt,
      ),
    );
  }

  DirectionSchedule _afterSequenceAnswer(
    CardDirection direction,
    ReviewOutcome outcome,
    Preset preset,
    DateTime answeredAt,
    DateTime? oppositeDueAt,
  ) {
    final sequenceStep = SequenceEngine.answer(
      currentStep: direction.step,
      outcome: outcome,
      preset: preset,
    );
    if (sequenceStep.acquired) {
      return const DirectionSchedule(
        state: DirectionState.acquired,
        step: null,
        dueAt: null,
      );
    } else {
      return DirectionSchedule(
        state: DirectionState.active,
        step: sequenceStep.step,
        dueAt: _dueAfter(
          sequenceStep.interval!,
          preset,
          answeredAt,
          oppositeDueAt,
        ),
      );
    }
  }

  /// FSRS counts the days elapsed since the previous answer; it gives a day
  /// or more, even after a failure: no review comes back the same day.
  DirectionSchedule _afterAdaptiveAnswer(
    CardDirection direction,
    ReviewOutcome outcome,
    Preset preset,
    DateTime answeredAt,
    DateTime? oppositeDueAt,
  ) {
    final lastReviewedAt = direction.lastReviewedAt;
    final memory = FsrsEngine.answer(
      memory: direction.memory,
      elapsedDays: lastReviewedAt == null
          ? 0
          : calendar.daysBetween(lastReviewedAt, answeredAt),
      rating: switch (outcome) {
        ReviewOutcome.correct => FsrsRating.good,
        ReviewOutcome.again => FsrsRating.again,
      },
    );
    final days = FsrsEngine.intervalDays(
      memory.stability,
      preset.targetRetention,
    );
    return DirectionSchedule(
      state: DirectionState.active,
      step: null,
      memory: memory,
      dueAt: _dueAfter(
        PresetInterval(days, IntervalUnit.day),
        preset,
        answeredAt,
        oppositeDueAt,
      ),
    );
  }

  DateTime _dueAfter(
    PresetInterval interval,
    Preset preset,
    DateTime answeredAt,
    DateTime? oppositeDueAt,
  ) {
    if (interval.isDayBased) {
      final dueDay = calendar.addDays(
        calendar.dayOf(answeredAt),
        interval.days,
      );
      final candidate = calendar.momentAt(dueDay, preset.dailySlot);
      return _spacedFromOpposite(candidate, preset, oppositeDueAt);
    } else {
      return answeredAt.add(interval.subDayDuration);
    }
  }

  DateTime _spacedFromOpposite(
    DateTime candidate,
    Preset preset,
    DateTime? oppositeDueAt,
  ) {
    if (oppositeDueAt != null && calendar.isSameDay(candidate, oppositeDueAt)) {
      final nextDay = calendar.addDays(calendar.dayOf(candidate), 1);
      return calendar.momentAt(nextDay, preset.dailySlot);
    } else {
      return candidate;
    }
  }
}
