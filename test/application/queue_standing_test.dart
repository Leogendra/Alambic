import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/distillation/queue_standing.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/distillation/distillation.dart';
import 'package:alambic/domain/distillation/distillation_rhythm.dart';
import 'package:alambic/domain/groups/sequence_end.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../domain/test_cards.dart';
import '../domain/test_presets.dart';

void main() {
  final now = DateTime(2026, 11, 10, 9);

  Distillation distillation({
    bool prioritizeReviews = false,
    DateTime? pausedAt,
  }) => Distillation(
    groupId: 1,
    cardsPerBatch: 1,
    prioritizeReviews: prioritizeReviews,
    pausedAt: pausedAt,
    startedAt: now,
    lastBatchDay: null,
    lastAdvancedDay: null,
  );

  /// Four cards waiting, ranked 0 to 3 in the order of their ids.
  final queue = [
    for (var id = 1; id <= 4; id++)
      testCard(id: id, state: CardState.pending, queuePosition: id - 1),
  ];

  QueueStanding? standing(
    Flashcard card, {
    List<Flashcard> others = const [],
    Distillation? of,
    bool globallyPaused = false,
  }) => QueueStanding.of(
    card,
    [...queue, ...others],
    distillation: of,
    globallyPaused: globallyPaused,
    preset: standardPreset,
    end: SequenceEnd.standard,
    rhythm: const DistillationRhythm(SchedulingCalendar()),
    now: now,
  );

  DateTime? arrival(QueueStanding? standing) => switch (standing?.arrival) {
    ExpectedArrival(:final day) => day,
    _ => null,
  };

  test('the rank among the waiting cards, from 1 for the head', () {
    final third = standing(queue[2], of: distillation())!;
    expect(third.rank, 3);
    expect(third.size, 4);
  });

  test('an introduced card has no standing', () {
    expect(standing(testCard(id: 9, dueAt: now)), isNull);
  });

  test('one card a day: the third comes out on the third day', () {
    expect(
      arrival(standing(queue[0], of: distillation())),
      DateTime(2026, 11, 10),
    );
    expect(
      arrival(standing(queue[2], of: distillation())),
      DateTime(2026, 11, 12),
    );
  });

  test('with "Prioritize reviews", a review of the group takes a place', () {
    final due = testCard(id: 9, step: 3, dueAt: DateTime(2026, 11, 11, 12));
    final of = distillation(prioritizeReviews: true);
    // The review on the 11th, then those of the first cards out, leave the
    // 11th and the 13th without new card.
    expect(
      arrival(standing(queue[2], others: [due], of: of))!,
      DateTime(2026, 11, 14),
    );
    expect(
      arrival(standing(queue[2], others: [due], of: distillation())),
      DateTime(2026, 11, 12),
      reason: 'without it, the batches go through',
    );
  });

  test('no date while the distillation or every distillation is paused', () {
    expect(
      standing(queue[0], of: distillation(pausedAt: now))!.arrival,
      isA<DistillationPaused>(),
    );
    expect(
      standing(queue[0], of: distillation(), globallyPaused: true)!.arrival,
      isA<DistillationPaused>(),
    );
  });

  test('no date when the group does not distill', () {
    expect(standing(queue[0])!.arrival, isA<NoDistillation>());
  });

  test('beyond two years, no date either', () {
    final long = [
      for (var id = 1; id <= 800; id++)
        testCard(id: id, state: CardState.pending, queuePosition: id),
    ];
    expect(
      QueueStanding.of(
        long.last,
        long,
        distillation: distillation(),
        globallyPaused: false,
        preset: standardPreset,
        end: SequenceEnd.standard,
        rhythm: const DistillationRhythm(SchedulingCalendar()),
        now: now,
      )!.arrival,
      isA<ArrivalBeyondHorizon>(),
    );
  });
}
