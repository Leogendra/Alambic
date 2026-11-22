import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/distillation/distillation_progress.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/distillation/distillation.dart';
import 'package:alambic/domain/distillation/distillation_rhythm.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../domain/test_cards.dart';

void main() {
  const rhythm = DistillationRhythm(SchedulingCalendar());
  final now = DateTime(2026, 11, 10, 9);

  Distillation distillation({DateTime? pausedAt}) => Distillation(
    groupId: 1,
    cardsPerBatch: 1,
    prioritizeReviews: true,
    pausedAt: pausedAt,
    startedAt: DateTime(2026, 11, 1),
    lastBatchDay: DateTime(2026, 11, 10),
    lastAdvancedDay: DateTime(2026, 11, 10),
  );

  final cards = [
    for (var id = 1; id <= 3; id++)
      testCard(id: id, state: CardState.pending, queuePosition: id),
    testCard(
      id: 11,
      dueAt: DateTime(2026, 11, 12, 12),
      lastReviewedAt: DateTime(2026, 11, 3, 12),
    ),
  ];

  DistillationProgress progress(
    Distillation distillation,
    List<Flashcard> cards, {
    bool globallyPaused = false,
  }) => DistillationProgress.of(
    distillation,
    cards,
    rhythm,
    now,
    globallyPaused: globallyPaused,
  );

  test('the last arrival slips by the batch days taken by reviews', () {
    final followed = progress(distillation(), cards);
    expect(followed.remaining, 3);
    expect(followed.lastArrival, DateTime(2026, 11, 14));
  });

  test('no arrival is planned while paused, on its own or globally', () {
    expect(
      progress(
        distillation(pausedAt: DateTime(2026, 11, 9)),
        cards,
      ).lastArrival,
      isNull,
    );
    expect(
      progress(distillation(), cards, globallyPaused: true).lastArrival,
      isNull,
    );
  });
}
