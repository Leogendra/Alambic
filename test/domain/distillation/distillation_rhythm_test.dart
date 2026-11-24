import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/distillation/distillation.dart';
import 'package:alambic/domain/distillation/distillation_rhythm.dart';
import 'package:alambic/domain/distillation/distillation_settings.dart';
import 'package:alambic/domain/groups/sequence_end.dart';
import 'package:alambic/domain/presets/interval_unit.dart';
import 'package:alambic/domain/presets/preset.dart';
import 'package:alambic/domain/presets/preset_interval.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../test_cards.dart';
import '../test_groups.dart';
import '../test_presets.dart';

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
        rhythm.nextIntroductionDay(distillation(lastBatchDay: today), today),
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
    const withoutPriority = DistillationSettings(
      cardsPerBatch: 3,
      prioritizeReviews: false,
    );

    // Every card is reviewed the day after its arrival, then acquired.
    final oneDay = standardPreset.copyWith(
      intervals: const [PresetInterval(1, IntervalUnit.day)],
    );

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

    Map<DateTime, int> forecast(
      DistillationSettings settings,
      List<Flashcard> cards, {
      Preset? preset,
      SequenceEnd end = acquiredEnd,
      DateTime? until,
    }) => rhythm.forecast(
      settings,
      cards,
      preset: preset ?? oneDay,
      end: end,
      firstDay: today,
      now: now,
      until: until,
    );

    test('without "Prioritize reviews", the batches follow until the queue '
        'is empty', () {
      expect(forecast(withoutPriority, queue(7)), {
        DateTime(2026, 11, 10): 3,
        DateTime(2026, 11, 11): 3,
        DateTime(2026, 11, 12): 1,
      });
    });

    test('without "Prioritize reviews", the reviews take no place', () {
      final cards = [
        ...queue(9),
        review(11, DateTime(2026, 11, 12, 12)),
        review(12, DateTime(2026, 11, 12, 18)),
        review(13, DateTime(2026, 11, 13, 12)),
      ];
      expect(forecast(withoutPriority, cards), {
        DateTime(2026, 11, 10): 3,
        DateTime(2026, 11, 11): 3,
        DateTime(2026, 11, 12): 3,
      });
    });

    test('the reviews of the cards to come take places too, so the last '
        'arrival slips', () {
      expect(forecast(settings, queue(9)), {
        DateTime(2026, 11, 10): 3,
        DateTime(2026, 11, 12): 3,
        DateTime(2026, 11, 14): 3,
      });
      expect(forecast(const DistillationSettings(cardsPerBatch: 1), queue(3)), {
        DateTime(2026, 11, 10): 1,
        DateTime(2026, 11, 12): 1,
        DateTime(2026, 11, 14): 1,
      });
    });

    test('the reviews planned on a batch day take places', () {
      final cards = [...queue(4), review(11, DateTime(2026, 11, 12, 12))];
      // The review planned on 11-12 leaves two places that day.
      expect(forecast(settings, cards), {
        DateTime(2026, 11, 10): 3,
        DateTime(2026, 11, 12): 1,
      });
    });

    test('the cards already introduced follow their whole sequence', () {
      final cards = [...queue(3), review(11, DateTime(2026, 11, 10, 12))];
      final preset = shortSequence();
      // Reviews of card 11: 11-10, 11-11, 11-13, 11-17. With one card a
      // day, 11-10 and 11-11 are taken and 11-12 is free; each arrival adds
      // its own reviews, 1, 3 and 7 days later.
      expect(
        forecast(
          const DistillationSettings(cardsPerBatch: 1),
          cards,
          preset: preset,
        ),
        {
          DateTime(2026, 11, 12): 1,
          DateTime(2026, 11, 14): 1,
          DateTime(2026, 11, 16): 1,
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
      expect(forecast(settings, cards, preset: shortSequence()), {
        DateTime(2026, 11, 10): 1,
        DateTime(2026, 11, 12): 3,
      });
    });

    test('a batch day taken by reviews brings nothing, and the next one '
        'goes on', () {
      final cards = [
        ...queue(2),
        for (var id = 11; id <= 13; id++)
          review(id, DateTime(2026, 11, 10, 12)),
      ];
      expect(forecast(settings, cards), {DateTime(2026, 11, 12): 2});
    });

    test('stops before the day given', () {
      expect(
        forecast(withoutPriority, queue(30), until: DateTime(2026, 11, 12)),
        {DateTime(2026, 11, 10): 3, DateTime(2026, 11, 11): 3},
      );
    });

    test('looks two years ahead, and leaves out what comes after', () {
      final arrivals = forecast(
        const DistillationSettings(cardsPerBatch: 1, prioritizeReviews: false),
        queue(1000),
      );
      expect(arrivals.length, DistillationRhythm.horizonDays);
      expect(arrivals.keys.last, DateTime(2028, 11, 8));
    });

    test('a group saturated with reviews stops at the horizon', () {
      final arrivals = forecast(
        const DistillationSettings(cardsPerBatch: 1),
        queue(1000),
      );
      // One arrival every other day: its review takes the day after.
      expect(arrivals.length, DistillationRhythm.horizonDays ~/ 2);
      expect(arrivals.keys.last.isBefore(DateTime(2028, 11, 10)), isTrue);
    });
  });

  test('a card of the queue comes out on the day the arrivals reach its '
      'rank', () {
    final arrivals = {
      DateTime(2026, 11, 10): 2,
      DateTime(2026, 11, 12): 1,
      DateTime(2026, 11, 13): 2,
    };
    expect(DistillationRhythm.arrivalDay(arrivals, 1), DateTime(2026, 11, 10));
    expect(DistillationRhythm.arrivalDay(arrivals, 2), DateTime(2026, 11, 10));
    expect(DistillationRhythm.arrivalDay(arrivals, 3), DateTime(2026, 11, 12));
    expect(DistillationRhythm.arrivalDay(arrivals, 5), DateTime(2026, 11, 13));
    expect(DistillationRhythm.arrivalDay(arrivals, 6), isNull);
  });
}
