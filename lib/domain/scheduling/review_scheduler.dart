import '../cards/direction_state.dart';
import '../presets/preset.dart';
import '../presets/preset_interval.dart';
import '../reviews/review_outcome.dart';
import 'direction_schedule.dart';
import 'scheduling_calendar.dart';
import 'sequence_engine.dart';

/// Turns an answer into the next due date of a direction.
///
/// Rules owned here:
/// - an interval of a day or more counts from the answer day and lands on the
///   preset slot; a shorter one counts from the answer moment;
/// - the two directions of a card are never due the same day: on a clash the
///   direction being scheduled moves to the next day.
class ReviewScheduler {
  const ReviewScheduler(this.calendar);

  final SchedulingCalendar calendar;

  DirectionSchedule afterAnswer({
    required int? currentStep,
    required ReviewOutcome outcome,
    required Preset preset,
    required DateTime answeredAt,
    required DateTime? oppositeDueAt,
  }) {
    final sequenceStep = SequenceEngine.answer(
      currentStep: currentStep,
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
  /// step, due the next day at the preset slot.
  DirectionSchedule postponed({
    required int? step,
    required Preset preset,
    required DateTime now,
    required DateTime? oppositeDueAt,
  }) {
    final nextDay = calendar.addDays(calendar.dayOf(now), 1);
    return DirectionSchedule(
      state: DirectionState.active,
      step: step,
      dueAt: _spacedFromOpposite(
        calendar.momentAt(nextDay, preset.dailySlot),
        preset,
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
