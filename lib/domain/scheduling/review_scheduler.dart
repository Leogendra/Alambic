import '../cards/card_state.dart';
import '../cards/flashcard.dart';
import '../presets/interval_unit.dart';
import '../presets/preset.dart';
import '../presets/preset_interval.dart';
import '../presets/scheduling_engine_kind.dart';
import '../reviews/review_outcome.dart';
import 'card_schedule.dart';
import 'fsrs/fsrs_engine.dart';
import 'fsrs/fsrs_rating.dart';
import 'scheduling_calendar.dart';
import 'sequence_engine.dart';

/// Turns an answer into the next due date of a card.
///
/// Rules owned here:
/// - the engine of the preset gives the interval: the next step of the
///   sequence, or the FSRS interval for the target retention;
/// - an interval of a day or more counts from the answer day and lands on the
///   preset slot; a shorter one counts from the answer moment.
class ReviewScheduler {
  const ReviewScheduler(this.calendar);

  final SchedulingCalendar calendar;

  CardSchedule afterAnswer({
    required Flashcard card,
    required ReviewOutcome outcome,
    required Preset preset,
    required DateTime answeredAt,
  }) => switch (preset.engine) {
    SchedulingEngineKind.sequence => _afterSequenceAnswer(
      card,
      outcome,
      preset,
      answeredAt,
    ),
    SchedulingEngineKind.adaptive => _afterAdaptiveAnswer(
      card,
      outcome,
      preset,
      answeredAt,
    ),
  };

  /// Schedule of a card introduced by its distillation: due today at the
  /// preset slot, so it is due right away even when the slot has already
  /// passed.
  CardSchedule introduction({required Preset preset, required DateTime now}) =>
      CardSchedule(
        state: CardState.active,
        step: null,
        dueAt: calendar.momentAt(calendar.dayOf(now), preset.dailySlot),
      );

  /// Schedule of a reminder held back by a distillation budget: the same
  /// progression, due the next day at the preset slot.
  CardSchedule postponed({
    required Flashcard card,
    required Preset preset,
    required DateTime now,
  }) => CardSchedule(
    state: CardState.active,
    step: card.step,
    memory: card.memory,
    dueAt: calendar.momentAt(
      calendar.addDays(calendar.dayOf(now), 1),
      preset.dailySlot,
    ),
  );

  CardSchedule _afterSequenceAnswer(
    Flashcard card,
    ReviewOutcome outcome,
    Preset preset,
    DateTime answeredAt,
  ) {
    final sequenceStep = SequenceEngine.answer(
      currentStep: card.step,
      outcome: outcome,
      preset: preset,
    );
    if (sequenceStep.acquired) {
      return const CardSchedule(
        state: CardState.acquired,
        step: null,
        dueAt: null,
      );
    } else {
      return CardSchedule(
        state: CardState.active,
        step: sequenceStep.step,
        dueAt: _dueAfter(sequenceStep.interval!, preset, answeredAt),
      );
    }
  }

  /// FSRS counts the days elapsed since the previous answer; it gives a day
  /// or more, even after a failure: no review comes back the same day.
  CardSchedule _afterAdaptiveAnswer(
    Flashcard card,
    ReviewOutcome outcome,
    Preset preset,
    DateTime answeredAt,
  ) {
    final lastReviewedAt = card.lastReviewedAt;
    final memory = FsrsEngine.answer(
      memory: card.memory,
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
    return CardSchedule(
      state: CardState.active,
      step: null,
      memory: memory,
      dueAt: _dueAfter(
        PresetInterval(days, IntervalUnit.day),
        preset,
        answeredAt,
      ),
    );
  }

  DateTime _dueAfter(
    PresetInterval interval,
    Preset preset,
    DateTime answeredAt,
  ) {
    if (interval.isDayBased) {
      final dueDay = calendar.addDays(
        calendar.dayOf(answeredAt),
        interval.days,
      );
      return calendar.momentAt(dueDay, preset.dailySlot);
    } else {
      return answeredAt.add(interval.subDayDuration);
    }
  }
}
