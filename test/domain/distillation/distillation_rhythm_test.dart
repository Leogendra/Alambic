import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/distillation/distillation.dart';
import 'package:alambic/domain/distillation/distillation_rhythm.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../test_cards.dart';

void main() {
  const rhythm = DistillationRhythm(SchedulingCalendar());

  Distillation distillation({
    int cardsPerBatch = 3,
    bool prioritizeReviews = true,
    DateTime? lastBatchDay,
    DateTime? lastAdvancedDay,
  }) => Distillation(
    groupId: 1,
    cardsPerBatch: cardsPerBatch,
    prioritizeReviews: prioritizeReviews,
    pausedAt: null,
    startedAt: DateTime(2026, 11, 10, 9),
    lastBatchDay: lastBatchDay,
    lastAdvancedDay: lastAdvancedDay,
  );

  test('the first batch is owed right away', () {
    expect(rhythm.batchDue(distillation(), DateTime(2026, 11, 10)), isTrue);
  });

  test('a batch is owed the day after the last one, and later on', () {
    final batched = distillation(lastBatchDay: DateTime(2026, 11, 10));
    expect(rhythm.batchDue(batched, DateTime(2026, 11, 10)), isFalse);
    expect(rhythm.batchDue(batched, DateTime(2026, 11, 11)), isTrue);
    expect(rhythm.batchDue(batched, DateTime(2026, 11, 17)), isTrue);
  });

  group('new cards of a batch', () {
    test('with "Prioritize reviews", each due card takes a place', () {
      const settings = DistillationSettings(cardsPerBatch: 3);
      expect(rhythm.newCards(settings, dueCards: 0), 3);
      expect(rhythm.newCards(settings, dueCards: 1), 2);
      expect(rhythm.newCards(settings, dueCards: 5), 0);
    });

    test('without it, the N cards whatever is due', () {
      const always = DistillationSettings(
        cardsPerBatch: 3,
        prioritizeReviews: false,
      );
      expect(rhythm.newCards(always, dueCards: 5), 3);
    });
  });

  group('next introduction', () {
    final today = DateTime(2026, 11, 10);

    test('today until its pass ran, tomorrow afterwards', () {
      expect(rhythm.nextIntroductionDay(distillation(), today), today);
      expect(
        rhythm.nextIntroductionDay(distillation(lastAdvancedDay: today), today),
        DateTime(2026, 11, 11),
      );
    });

    test('the day after the last batch', () {
      expect(
        rhythm.nextIntroductionDay(
          distillation(lastBatchDay: today),
          today,
        ),
        DateTime(2026, 11, 11),
      );
    });

    test('never before today after a long gap', () {
      expect(
        rhythm.nextIntroductionDay(
          distillation(lastBatchDay: DateTime(2026, 11, 1)),
          today,
        ),
        today,
      );
    });
  });

  group('forecast', () {
    final now = DateTime(2026, 11, 10, 9);
    final today = DateTime(2026, 11, 10);
    final lastWeek = DateTime(2026, 11, 3, 12);
    const settings = DistillationSettings(cardsPerBatch: 3);

    List<Flashcard> queue(int count) => [
      for (var id = 1; id <= count; id++)
        testCard(id: id, state: CardState.pending, queuePosition: id),
    ];

    Flashcard review(int id, DateTime dueAt, {DateTime? lastReviewedAt}) =>
        testCard(
          id: id,
          dueAt: dueAt,
          lastReviewedAt: lastReviewedAt ?? lastWeek,
        );

    test('follows the batches until the queue is empty', () {
      expect(rhythm.forecast(settings, queue(7), firstDay: today, now: now), {
        DateTime(2026, 11, 10): 3,
        DateTime(2026, 11, 11): 3,
        DateTime(2026, 11, 12): 1,
      });
    });

    test('the reviews planned on a batch day take places, so the last '
        'arrival slips', () {
      final cards = [
        ...queue(9),
        review(11, DateTime(2026, 11, 12, 12)),
        review(12, DateTime(2026, 11, 12, 18)),
        review(13, DateTime(2026, 11, 13, 12)),
      ];
      expect(rhythm.forecast(settings, cards, firstDay: today, now: now), {
        DateTime(2026, 11, 10): 3,
        DateTime(2026, 11, 11): 3,
        DateTime(2026, 11, 12): 1,
        DateTime(2026, 11, 13): 2,
      });
      expect(
        rhythm.forecast(
          const DistillationSettings(
            cardsPerBatch: 3,
            prioritizeReviews: false,
          ),
          cards,
          firstDay: today,
          now: now,
        ),
        {
          DateTime(2026, 11, 10): 3,
          DateTime(2026, 11, 11): 3,
          DateTime(2026, 11, 12): 3,
        },
      );
    });

    test('today counts the cards due at the moment, late ones included', () {
      final cards = [
        ...queue(4),
        review(11, DateTime(2026, 11, 8, 12)),
        review(12, DateTime(2026, 11, 10, 12)),
        review(
          13,
          DateTime(2026, 11, 10, 15),
          lastReviewedAt: DateTime(2026, 11, 10, 8),
        ),
      ];
      expect(rhythm.forecast(settings, cards, firstDay: today, now: now), {
        DateTime(2026, 11, 10): 1,
        DateTime(2026, 11, 11): 3,
      });
    });

    test('a batch day taken by reviews brings nothing, and the next one '
        'goes on', () {
      final cards = [
        ...queue(2),
        for (var id = 11; id <= 13; id++)
          review(id, DateTime(2026, 11, 10, 12)),
      ];
      expect(rhythm.forecast(settings, cards, firstDay: today, now: now), {
        DateTime(2026, 11, 11): 2,
      });
    });

    test('stops before the day given', () {
      expect(
        rhythm.forecast(
          settings,
          queue(30),
          firstDay: today,
          now: now,
          until: DateTime(2026, 11, 12),
        ),
        {DateTime(2026, 11, 10): 3, DateTime(2026, 11, 11): 3},
      );
    });
  });
}
