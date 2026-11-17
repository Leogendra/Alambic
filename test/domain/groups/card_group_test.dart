import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/domain/cards/card_side.dart';

import '../test_cards.dart';
import '../test_groups.dart';

void main() {
  group('a card is answered by typing', () {
    test('only with the typed answer option', () {
      final card = testCard();
      expect(
        testGroup(typedAnswer: true).asksTypedAnswer(card, CardSide.front),
        isTrue,
      );
      expect(testGroup().asksTypedAnswer(card, CardSide.front), isFalse);
    });

    test('only when the answer face has text', () {
      final card = testCard(frontText: null, frontImagePath: 'flag.png');
      final typed = testGroup(typedAnswer: true);
      expect(typed.asksTypedAnswer(card, CardSide.back), isFalse);
      expect(typed.asksTypedAnswer(card, CardSide.front), isTrue);
    });
  });
}
