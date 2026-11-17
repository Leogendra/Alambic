import '../cards/card_state.dart';
import '../cards/flashcard.dart';
import '../presets/preset.dart';
import '../presets/preset_interval.dart';
import '../reviews/review_outcome.dart';
import 'card_schedule.dart';
import 'clock_time.dart';
import 'scheduling_calendar.dart';
import 'sequence_engine.dart';

/// Turns an answer into the next due date of a card.
///
/// Rules owned here:
/// - the sequence of the preset gives the interval of the step reached;
/// - an interval of a day or more counts from the answer day and lands on the
///   daily slot of the app; a shorter one counts from the answer moment.
class ReviewScheduler {
  const ReviewScheduler(this.calendar);

  final SchedulingCalendar calendar;

  CardSchedule afterAnswer({
    required Flashcard card,
    required ReviewOutcome outcome,
    required Preset preset,
    required DateTime answeredAt,
    required ClockTime dailySlot,
  }) {
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
        dueAt: _dueAfter(sequenceStep.interval!, answeredAt, dailySlot),
      );
    }
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

  /// Schedule of a reminder held back by a distillation budget: the same
  /// progression, due the next day at the daily slot.
  CardSchedule postponed({
    required Flashcard card,
    required ClockTime dailySlot,
    required DateTime now,
  }) => CardSchedule(
    state: CardState.active,
    step: card.step,
    dueAt: calendar.momentAt(
      calendar.addDays(calendar.dayOf(now), 1),
      dailySlot,
    ),
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
