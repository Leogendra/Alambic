import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/presets/sequence_end_behavior.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/scheduling/clock_time.dart';
import 'package:alambic/domain/scheduling/review_scheduler.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../test_cards.dart';
import '../test_presets.dart';

/// An active card at [step], last answered at [lastReviewedAt].
Flashcard answered({int? step, DateTime? lastReviewedAt}) =>
    testCard(step: step, lastReviewedAt: lastReviewedAt);

void main() {
  const scheduler = ReviewScheduler(SchedulingCalendar());
  const noon = ClockTime(12, 0);

  group('day-based intervals', () {
    test('count from the answer day and land on the daily slot', () {
      final schedule = scheduler.afterAnswer(
        card: answered(step: 0),
        outcome: ReviewOutcome.correct,
        preset: standardPreset,
        answeredAt: DateTime(2026, 11, 10, 21, 30),
        dailySlot: noon,
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
        dailySlot: noon,
      );
      expect(schedule.dueAt, DateTime(2026, 11, 11, 12));
    });

    test('a failure waits the interval of the step reached, never today', () {
      final schedule = scheduler.afterAnswer(
        card: answered(step: 3),
        outcome: ReviewOutcome.again,
        preset: standardPreset,
        answeredAt: DateTime(2026, 11, 10, 12, 5),
        dailySlot: noon,
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
      dailySlot: noon,
    );
    expect(schedule.dueAt, DateTime(2026, 11, 10, 15, 17));
  });

  test('an acquired card has no due date', () {
    final schedule = scheduler.afterAnswer(
      card: answered(step: 2),
      outcome: ReviewOutcome.correct,
      preset: shortSequence(endBehavior: SequenceEndBehavior.markAcquired),
      answeredAt: DateTime(2026, 11, 10, 12),
      dailySlot: noon,
    );
    expect(schedule.state, CardState.acquired);
    expect(schedule.dueAt, isNull);
  });

  group('introduction', () {
    test('is today at the slot when it is still ahead', () {
      final schedule = scheduler.introduction(
        dailySlot: noon,
        now: DateTime(2026, 11, 10, 9),
      );
      expect(schedule.dueAt, DateTime(2026, 11, 10, 12));
      expect(schedule.step, isNull);
      expect(schedule.state, CardState.active);
    });

    test('stays today when the slot has passed, so it is due at once', () {
      final schedule = scheduler.introduction(
        dailySlot: noon,
        now: DateTime(2026, 11, 10, 15),
      );
      expect(schedule.dueAt, DateTime(2026, 11, 10, 12));
    });
  });
}
