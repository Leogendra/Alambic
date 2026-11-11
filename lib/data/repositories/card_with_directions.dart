import '../../domain/cards/card_direction.dart';
import '../../domain/cards/direction_sense.dart';
import '../../domain/cards/flashcard.dart';

/// A card with its directions, as shown in lists and on the card sheet.
class CardWithDirections {
  const CardWithDirections({required this.card, required this.directions});

  final Flashcard card;
  final List<CardDirection> directions;

  CardDirection? direction(DirectionSense sense) {
    for (final direction in directions) {
      if (direction.sense == sense) {
        return direction;
      }
    }
    return null;
  }
}
