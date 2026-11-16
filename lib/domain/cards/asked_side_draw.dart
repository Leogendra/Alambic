import 'dart:math';

import '../groups/card_group.dart';
import 'card_side.dart';

/// Which face a display of a card asks.
///
/// Without the back enabled on its group, always the front. With it, the
/// front or the back, one chance in two, drawn again at every display. The
/// draw is visual only: it is neither stored nor followed, and changes
/// nothing to the progression of the card.
abstract final class AskedSideDraw {
  static CardSide draw(CardGroup group, Random random) =>
      group.reverseEnabled && random.nextBool()
      ? CardSide.back
      : CardSide.front;
}
