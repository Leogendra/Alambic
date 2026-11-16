import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/reviews/review_session.dart';
import 'package:alambic/application/reviews/session_item.dart';
import 'package:alambic/domain/cards/card_side.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';

void main() {
  const first = SessionItem(cardId: 1, askedSide: CardSide.front);
  const second = SessionItem(cardId: 2, askedSide: CardSide.back);
  const third = SessionItem(cardId: 3, askedSide: CardSide.front);

  ReviewSession session() => ReviewSession(
    items: const [first, second, third],
    isBonus: false,
    startedAt: DateTime(2026, 11, 10, 12),
  );

  test('walks the items in order and ends after the last one', () {
    final reviewSession = session();
    expect(reviewSession.current, first);
    reviewSession.record(ReviewOutcome.correct);
    expect(reviewSession.current, second);
    reviewSession
      ..record(ReviewOutcome.again)
      ..record(ReviewOutcome.correct);
    expect(reviewSession.isFinished, isTrue);
    expect(reviewSession.current, isNull);
    expect(() => reviewSession.record(ReviewOutcome.correct), throwsStateError);
  });

  test('counts the answers and keeps the missed items', () {
    final reviewSession = session()
      ..record(ReviewOutcome.again)
      ..record(ReviewOutcome.correct)
      ..record(ReviewOutcome.again);
    expect(reviewSession.correctCount, 1);
    expect(reviewSession.againCount, 2);
    expect(reviewSession.missedItems, [first, third]);
  });
}
