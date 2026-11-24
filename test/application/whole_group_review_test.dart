import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/reviews/whole_group_review.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/scheduling/due_policy.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../domain/test_cards.dart';

void main() {
  const review = WholeGroupReview(DuePolicy(SchedulingCalendar()));
  final now = DateTime(2026, 11, 10, 15);

  test('due cards first, then introduced ones, then the queue', () {
    final cards = [
      testCard(id: 1, state: CardState.pending, queuePosition: 2),
      testCard(id: 2, dueAt: DateTime(2026, 11, 14, 12)),
      testCard(id: 3, dueAt: DateTime(2026, 11, 10, 12)),
      testCard(id: 4, state: CardState.pending, queuePosition: 1),
      testCard(id: 5, dueAt: DateTime(2026, 11, 12, 12)),
      testCard(id: 6, dueAt: DateTime(2026, 11, 9, 12)),
    ];
    expect(review.cardIds(cards, now), [6, 3, 5, 2, 4, 1]);
  });

  test('acquired cards are left out', () {
    final cards = [
      testCard(id: 1, state: CardState.completed),
      testCard(id: 2, dueAt: DateTime(2026, 12, 1, 12)),
    ];
    expect(review.cardIds(cards, now), [2]);
  });
}
