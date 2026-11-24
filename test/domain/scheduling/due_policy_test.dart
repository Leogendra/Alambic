import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_state.dart';
import 'package:alambic/domain/cards/flashcard.dart';
import 'package:alambic/domain/scheduling/due_policy.dart';
import 'package:alambic/domain/scheduling/scheduling_calendar.dart';

import '../test_cards.dart';

Flashcard card({
  CardState state = CardState.active,
  DateTime? dueAt,
  DateTime? lastReviewedAt,
}) => testCard(
  state: state,
  step: 0,
  dueAt: dueAt,
  lastReviewedAt: lastReviewedAt,
);

void main() {
  const policy = DuePolicy(SchedulingCalendar());
  final now = DateTime(2026, 11, 10, 9);

  bool isDue(Flashcard value) => policy.isDueToday(value, now: now);

  test('a past due moment is due', () {
    expect(isDue(card(dueAt: DateTime(2026, 11, 8, 12))), isTrue);
  });

  test('a due later today is due before its slot', () {
    expect(isDue(card(dueAt: DateTime(2026, 11, 10, 12))), isTrue);
  });

  test('a due tomorrow is not due', () {
    expect(isDue(card(dueAt: DateTime(2026, 11, 11, 12))), isFalse);
  });

  test('a sub-day interval answered today waits for its moment', () {
    final waiting = card(
      dueAt: DateTime(2026, 11, 10, 9, 10),
      lastReviewedAt: DateTime(2026, 11, 10, 9),
    );
    expect(isDue(waiting), isFalse);
  });

  test('acquired or pending cards are never due', () {
    final past = DateTime(2026, 11, 8);
    expect(isDue(card(state: CardState.completed)), isFalse);
    expect(isDue(card(dueAt: past, state: CardState.pending)), isFalse);
  });
}
