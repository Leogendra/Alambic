import 'dart:math';

import '../groups/asked_sides.dart';
import '../groups/card_group.dart';
import 'card_side.dart';

/// Which face a display of a card asks.
///
/// The front or the back, as set on its group, or one of the two, one
/// chance in two, drawn again at every display. The draw is visual only: it
/// is neither stored nor followed, and changes nothing to the progression of
/// the card.
abstract final class AskedSideDraw {
  static CardSide draw(CardGroup group, Random random) =>
      switch (group.askedSides) {
        AskedSides.front => CardSide.front,
        AskedSides.back => CardSide.back,
        AskedSides.random => random.nextBool() ? CardSide.back : CardSide.front,
      };
}
