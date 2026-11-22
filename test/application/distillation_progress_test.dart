import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/distillation/distillation_progress.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/distillation/distillation.dart';

import '../domain/test_cards.dart';

void main() {
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

  test('only the waiting cards of the group are counted', () {
    expect(DistillationProgress.of(distillation(), cards).remaining, 3);
  });
}
