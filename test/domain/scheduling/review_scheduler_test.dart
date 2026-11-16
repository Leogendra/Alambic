import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/presets/built_in_presets.dart';
import 'package:alambic/domain/presets/sequence_end_behavior.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/scheduling/review_scheduler.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../test_cards.dart';
import '../test_presets.dart';

/// An active card at [step], last answered at [lastReviewedAt].
Flashcard answered({
  int? step,
  double? stability,
  double? difficulty,
  DateTime? lastReviewedAt,
}) => testCard(
  step: step,
  stability: stability,
  difficulty: difficulty,
  lastReviewedAt: lastReviewedAt,
);

void main() {
  const scheduler = ReviewScheduler(SchedulingCalendar());

  group('day-based intervals', () {
    test('count from the answer day and land on the preset slot', () {
      final schedule = scheduler.afterAnswer(
        card: answered(step: 0),
        outcome: ReviewOutcome.correct,
        preset: standardPreset,
        answeredAt: DateTime(2026, 11, 10, 21, 30),
      );
      expect(schedule.dueAt, DateTime(2026, 11, 12, 12));
      expect(schedule.step, 1);
      expect(schedule.state, CardState.active);
    });

    test('an answer before 4am counts for the previous day', () {
      final schedule = scheduler.afterAnswer(
        card: answered(step: null),
        outcome: ReviewOutcome.correct,
        preset: standardPreset,
        answeredAt: DateTime(2026, 11, 11, 1),
      );
      expect(schedule.dueAt, DateTime(2026, 11, 11, 12));
    });

    test('a failure waits the interval of the step reached, never today', () {
      final schedule = scheduler.afterAnswer(
        card: answered(step: 3),
        outcome: ReviewOutcome.again,
        preset: standardPreset,
        answeredAt: DateTime(2026, 11, 10, 12, 5),
      );
      expect(schedule.step, 2);
      expect(schedule.dueAt, DateTime(2026, 11, 17, 12));
    });
  });

  test('sub-day intervals count from the answer moment', () {
    final schedule = scheduler.afterAnswer(
      card: answered(step: null),
      outcome: ReviewOutcome.correct,
      preset: intensivePreset,
      answeredAt: DateTime(2026, 11, 10, 15, 7),
    );
    expect(schedule.dueAt, DateTime(2026, 11, 10, 15, 17));
  });

  test('an acquired card has no due date', () {
    final schedule = scheduler.afterAnswer(
      card: answered(step: 2),
      outcome: ReviewOutcome.correct,
      preset: shortSequence(endBehavior: SequenceEndBehavior.markAcquired),
      answeredAt: DateTime(2026, 11, 10, 12),
    );
    expect(schedule.state, CardState.acquired);
    expect(schedule.dueAt, isNull);
  });

  group('introduction', () {
    test('is today at the slot when it is still ahead', () {
      final schedule = scheduler.introduction(
        preset: standardPreset,
        now: DateTime(2026, 11, 10, 9),
      );
      expect(schedule.dueAt, DateTime(2026, 11, 10, 12));
      expect(schedule.step, isNull);
      expect(schedule.state, CardState.active);
    });

    test('stays today when the slot has passed, so it is due at once', () {
      final schedule = scheduler.introduction(
        preset: standardPreset,
        now: DateTime(2026, 11, 10, 15),
      );
      expect(schedule.dueAt, DateTime(2026, 11, 10, 12));
    });
  });

  group('adaptive engine', () {
    final adaptive = BuiltInPresets.adaptive.copyWith(id: 4);

    test('a first Correct comes back in 3 days at the slot', () {
      final schedule = scheduler.afterAnswer(
        card: answered(),
        outcome: ReviewOutcome.correct,
        preset: adaptive,
        answeredAt: DateTime(2026, 11, 10, 12, 5),
      );
      expect(schedule.state, CardState.active);
      expect(schedule.step, isNull);
      expect(schedule.memory?.stability, 3.173);
      expect(schedule.dueAt, DateTime(2026, 11, 13, 12));
    });

    test('a failure comes back the next day, never the same day', () {
      final schedule = scheduler.afterAnswer(
        card: answered(),
        outcome: ReviewOutcome.again,
        preset: adaptive,
        answeredAt: DateTime(2026, 11, 10, 12, 5),
      );
      expect(schedule.dueAt, DateTime(2026, 11, 11, 12));
    });

    test('counts the days elapsed since the previous answer', () {
      final schedule = scheduler.afterAnswer(
        card: answered(
          stability: 3.173,
          difficulty: 5.282,
          lastReviewedAt: DateTime(2026, 11, 10, 12, 5),
        ),
        outcome: ReviewOutcome.correct,
        preset: adaptive,
        answeredAt: DateTime(2026, 11, 13, 12, 2),
      );
      expect(schedule.memory!.stability, closeTo(10.739, 0.01));
      expect(schedule.dueAt, DateTime(2026, 11, 24, 12));
    });

    test('a lower target retention spaces the reviews more', () {
      final schedule = scheduler.afterAnswer(
        card: answered(
          stability: 3.173,
          difficulty: 5.282,
          lastReviewedAt: DateTime(2026, 11, 10, 12, 5),
        ),
        outcome: ReviewOutcome.correct,
        preset: adaptive.copyWith(targetRetention: 0.8),
        answeredAt: DateTime(2026, 11, 13, 12, 2),
      );
      expect(schedule.dueAt, DateTime(2026, 12, 9, 12));
    });
  });

  group('a change of engine starts over', () {
    test('a sequence step means nothing to FSRS', () {
      final schedule = scheduler.afterAnswer(
        card: answered(step: 4, lastReviewedAt: DateTime(2026, 8, 10, 12)),
        outcome: ReviewOutcome.correct,
        preset: BuiltInPresets.adaptive.copyWith(id: 4),
        answeredAt: DateTime(2026, 11, 10, 12, 5),
      );
      expect(schedule.step, isNull);
      expect(schedule.memory?.stability, 3.173);
      expect(schedule.dueAt, DateTime(2026, 11, 13, 12));
    });

    test('an FSRS memory means nothing to a sequence, and is dropped', () {
      final schedule = scheduler.afterAnswer(
        card: answered(
          stability: 120,
          difficulty: 4,
          lastReviewedAt: DateTime(2026, 8, 10, 12),
        ),
        outcome: ReviewOutcome.correct,
        preset: standardPreset,
        answeredAt: DateTime(2026, 11, 10, 12, 5),
      );
      expect(schedule.step, 0);
      expect(schedule.memory, isNull);
      expect(schedule.dueAt, DateTime(2026, 11, 11, 12));
    });
  });
}
