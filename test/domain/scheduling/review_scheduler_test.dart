import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/groups/remanence_interval.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/scheduling/card_schedule.dart';
import 'package:alambic/domain/scheduling/clock_time.dart';
import 'package:alambic/domain/scheduling/review_scheduler.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../test_cards.dart';
import '../test_groups.dart';
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
        end: remanence(),
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
        end: remanence(),
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
        end: remanence(),
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
      end: remanence(),
      answeredAt: DateTime(2026, 11, 10, 15, 7),
      dailySlot: noon,
    );
    expect(schedule.dueAt, DateTime(2026, 11, 10, 15, 17));
  });

  test('an acquired card has no due date', () {
    final schedule = scheduler.afterAnswer(
      card: answered(step: 2),
      outcome: ReviewOutcome.correct,
      preset: shortSequence(),
      end: acquiredEnd,
      answeredAt: DateTime(2026, 11, 10, 12),
      dailySlot: noon,
    );
    expect(schedule.state, CardState.completed);
    expect(schedule.dueAt, isNull);
  });

  group('remanence', () {
    test('a card past its last step is completed, without step, due at the '
        'remanence interval on the daily slot', () {
      final schedule = scheduler.afterAnswer(
        card: answered(step: 2),
        outcome: ReviewOutcome.correct,
        preset: shortSequence(),
        end: remanence(),
        answeredAt: DateTime(2026, 11, 10, 21),
        dailySlot: noon,
      );
      expect(schedule.state, CardState.completed);
      expect(schedule.step, isNull);
      expect(schedule.dueAt, DateTime(2027, 5, 9, 12));
    });

    test('a failure stepping back leaves the remanence', () {
      final schedule = scheduler.afterAnswer(
        card: testCard(
          state: CardState.completed,
          dueAt: DateTime(2026, 11, 10, 12),
        ),
        outcome: ReviewOutcome.again,
        preset: shortSequence(),
        end: remanence(),
        answeredAt: DateTime(2026, 11, 10, 12),
        dailySlot: noon,
      );
      expect(schedule.state, CardState.active);
      expect(schedule.step, 2);
      expect(schedule.dueAt, DateTime(2026, 11, 14, 12));
    });

    group('an acquired card switched back to remanence', () {
      CardSchedule backToRemanence(DateTime lastReviewedAt) =>
          scheduler.backToRemanence(
            lastReviewedAt: lastReviewedAt,
            preset: shortSequence(),
            end: remanence(RemanenceInterval.threeMonths),
            now: DateTime(2026, 11, 10, 9),
            dailySlot: noon,
          );

      test('is due one remanence interval after its last review', () {
        final schedule = backToRemanence(DateTime(2026, 9, 20, 21));
        expect(schedule.state, CardState.completed);
        expect(schedule.step, isNull);
        expect(schedule.dueAt, DateTime(2026, 12, 19, 12));
      });

      test('stays due today when that day is today', () {
        expect(
          backToRemanence(DateTime(2026, 8, 12, 9)).dueAt,
          DateTime(2026, 11, 10, 12),
        );
      });

      test('is due one remanence interval from today when that day has '
          'passed', () {
        expect(
          backToRemanence(DateTime(2026, 8, 11, 9)).dueAt,
          DateTime(2027, 2, 8, 12),
        );
      });
    });
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
