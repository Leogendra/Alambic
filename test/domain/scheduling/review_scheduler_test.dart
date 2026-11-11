import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/domain/cards/direction_state.dart';
import 'package:remanence/domain/presets/sequence_end_behavior.dart';
import 'package:remanence/domain/reviews/review_outcome.dart';
import 'package:remanence/domain/scheduling/review_scheduler.dart';
import 'package:remanence/domain/scheduling/scheduling_calendar.dart';

import '../test_presets.dart';

void main() {
  const scheduler = ReviewScheduler(SchedulingCalendar());

  group('day-based intervals', () {
    test('count from the answer day and land on the preset slot', () {
      final schedule = scheduler.afterAnswer(
        currentStep: 0,
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
        currentStep: null,
        outcome: ReviewOutcome.correct,
        preset: standardPreset,
        answeredAt: DateTime(2026, 11, 11, 1),
        oppositeDueAt: null,
      );
      expect(schedule.dueAt, DateTime(2026, 11, 11, 12));
    });

    test('a failure waits the interval of the step reached, never today', () {
      final schedule = scheduler.afterAnswer(
        currentStep: 3,
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
      currentStep: null,
      outcome: ReviewOutcome.correct,
      preset: intensivePreset,
      answeredAt: DateTime(2026, 11, 10, 15, 7),
      oppositeDueAt: null,
    );
    expect(schedule.dueAt, DateTime(2026, 11, 10, 15, 17));
  });

  test('the opposite direction due the same day pushes to the next day', () {
    final schedule = scheduler.afterAnswer(
      currentStep: null,
      outcome: ReviewOutcome.correct,
      preset: standardPreset,
      answeredAt: DateTime(2026, 11, 10, 12),
      oppositeDueAt: DateTime(2026, 11, 11, 12),
    );
    expect(schedule.dueAt, DateTime(2026, 11, 12, 12));
  });

  test('an acquired direction has no due date', () {
    final schedule = scheduler.afterAnswer(
      currentStep: 2,
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
}
