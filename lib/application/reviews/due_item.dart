import '../../data/repositories/card_with_directions.dart';
import '../../domain/cards/card_direction.dart';

/// A direction to review, with its card.
class DueItem {
  const DueItem({required this.card, required this.direction});

  final CardWithDirections card;
  final CardDirection direction;

  int? get groupId => card.card.groupId;
}
