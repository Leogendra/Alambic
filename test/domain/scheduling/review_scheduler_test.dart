import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_direction.dart';
import 'package:alambic/domain/cards/direction_sense.dart';
import 'package:alambic/domain/cards/direction_state.dart';
import 'package:alambic/domain/presets/built_in_presets.dart';
import 'package:alambic/domain/presets/sequence_end_behavior.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/scheduling/review_scheduler.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../test_presets.dart';

/// An active direction at [step], last answered at [lastReviewedAt].
CardDirection answered({
  int? step,
  double? stability,
  double? difficulty,
  DateTime? lastReviewedAt,
}) => CardDirection(
  id: 1,
  cardId: 1,
  sense: DirectionSense.frontToBack,
  state: DirectionState.active,
  step: step,
  stability: stability,
  difficulty: difficulty,
  dueAt: null,
  lastReviewedAt: lastReviewedAt,
  notifiedAt: null,
  distillationId: null,
  queuePosition: null,
);

void main() {
  const scheduler = ReviewScheduler(SchedulingCalendar());

  group('day-based intervals', () {
    test('count from the answer day and land on the preset slot', () {
      final schedule = scheduler.afterAnswer(
        direction: answered(step: 0),
        outcome: ReviewOutcome.correct,
        preset: standardPreset,
        answeredAt: DateTime(2026, 11, 10, 21, 30),
        oppositeDueAt: null,
      );
      expect(schedule.dueAt, DateTime(2026, 11, 12, 12));
      expect(schedule.step, 1);
      expect(schedule.state, DirectionState.active);
    });

    test('an answer before 4am counts for the previous day', () {
      final schedule = scheduler.afterAnswer(
        direction: answered(step: null),
        outcome: ReviewOutcome.correct,
        preset: standardPreset,
        answeredAt: DateTime(2026, 11, 11, 1),
        oppositeDueAt: null,
      );
      expect(schedule.dueAt, DateTime(2026, 11, 11, 12));
    });

    test('a failure waits the interval of the step reached, never today', () {
      final schedule = scheduler.afterAnswer(
        direction: answered(step: 3),
        outcome: ReviewOutcome.again,
        preset: standardPreset,
        answeredAt: DateTime(2026, 11, 10, 12, 5),
        oppositeDueAt: null,
      );
      expect(schedule.step, 2);
      expect(schedule.dueAt, DateTime(2026, 11, 17, 12));
    });
  });

  test('sub-day intervals count from the answer moment', () {
    final schedule = scheduler.afterAnswer(
      direction: answered(step: null),
      outcome: ReviewOutcome.correct,
      preset: intensivePreset,
      answeredAt: DateTime(2026, 11, 10, 15, 7),
      oppositeDueAt: null,
    );
    expect(schedule.dueAt, DateTime(2026, 11, 10, 15, 17));
  });

  test('the opposite direction due the same day pushes to the next day', () {
    final schedule = scheduler.afterAnswer(
      direction: answered(step: null),
      outcome: ReviewOutcome.correct,
      preset: standardPreset,
      answeredAt: DateTime(2026, 11, 10, 12),
      oppositeDueAt: DateTime(2026, 11, 11, 12),
    );
    expect(schedule.dueAt, DateTime(2026, 11, 12, 12));
  });

  test('an acquired direction has no due date', () {
    final schedule = scheduler.afterAnswer(
      direction: answered(step: 2),
      outcome: ReviewOutcome.correct,
      preset: shortSequence(endBehavior: SequenceEndBehavior.markAcquired),
      answeredAt: DateTime(2026, 11, 10, 12),
      oppositeDueAt: null,
    );
    expect(schedule.state, DirectionState.acquired);
    expect(schedule.dueAt, isNull);
  });

  group('start schedule', () {
    test('is today at the slot when it is still ahead', () {
      final schedule = scheduler.startSchedule(
        preset: standardPreset,
        now: DateTime(2026, 11, 10, 9),
        oppositeDueAt: null,
      );
      expect(schedule.dueAt, DateTime(2026, 11, 10, 12));
      expect(schedule.step, isNull);
      expect(schedule.state, DirectionState.active);
    });

    test('stays today when the slot has passed, so it is due at once', () {
      final schedule = scheduler.startSchedule(
        preset: standardPreset,
        now: DateTime(2026, 11, 10, 15),
        oppositeDueAt: null,
      );
      expect(schedule.dueAt, DateTime(2026, 11, 10, 12));
    });

    test('of the reverse direction avoids the day of the front one', () {
      final schedule = scheduler.startSchedule(
        preset: standardPreset,
        now: DateTime(2026, 11, 10, 9),
        oppositeDueAt: DateTime(2026, 11, 10, 12),
      );
      expect(schedule.dueAt, DateTime(2026, 11, 11, 12));
    });
  });

  group('adaptive engine', () {
    final adaptive = BuiltInPresets.adaptive.copyWith(id: 4);

    test('a first Correct comes back in 3 days at the slot', () {
      final schedule = scheduler.afterAnswer(
        direction: answered(),
        outcome: ReviewOutcome.correct,
        preset: adaptive,
        answeredAt: DateTime(2026, 11, 10, 12, 5),
        oppositeDueAt: null,
      );
      expect(schedule.state, DirectionState.active);
      expect(schedule.step, isNull);
      expect(schedule.memory?.stability, 3.173);
      expect(schedule.dueAt, DateTime(2026, 11, 13, 12));
    });

    test('a failure comes back the next day, never the same day', () {
      final schedule = scheduler.afterAnswer(
        direction: answered(),
        outcome: ReviewOutcome.again,
        preset: adaptive,
        answeredAt: DateTime(2026, 11, 10, 12, 5),
        oppositeDueAt: null,
      );
      expect(schedule.dueAt, DateTime(2026, 11, 11, 12));
    });

    test('counts the days elapsed since the previous answer', () {
      final schedule = scheduler.afterAnswer(
        direction: answered(
          stability: 3.173,
          difficulty: 5.282,
          lastReviewedAt: DateTime(2026, 11, 10, 12, 5),
        ),
        outcome: ReviewOutcome.correct,
        preset: adaptive,
        answeredAt: DateTime(2026, 11, 13, 12, 2),
        oppositeDueAt: null,
      );
      expect(schedule.memory!.stability, closeTo(10.739, 0.01));
      expect(schedule.dueAt, DateTime(2026, 11, 24, 12));
    });

    test('a lower target retention spaces the reviews more', () {
      final schedule = scheduler.afterAnswer(
        direction: answered(
          stability: 3.173,
          difficulty: 5.282,
          lastReviewedAt: DateTime(2026, 11, 10, 12, 5),
        ),
        outcome: ReviewOutcome.correct,
        preset: adaptive.copyWith(targetRetention: 0.8),
        answeredAt: DateTime(2026, 11, 13, 12, 2),
        oppositeDueAt: null,
      );
      expect(schedule.dueAt, DateTime(2026, 12, 9, 12));
    });

    test('keeps the two directions on different days', () {
      final schedule = scheduler.afterAnswer(
        direction: answered(),
        outcome: ReviewOutcome.correct,
        preset: adaptive,
        answeredAt: DateTime(2026, 11, 10, 12, 5),
        oppositeDueAt: DateTime(2026, 11, 13, 12),
      );
      expect(schedule.dueAt, DateTime(2026, 11, 14, 12));
    });
  });
}
