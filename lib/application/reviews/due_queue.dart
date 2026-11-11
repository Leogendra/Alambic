import '../../data/repositories/card_with_directions.dart';
import '../../domain/scheduling/due_policy.dart';
import 'due_item.dart';

/// Builds the list of directions to review now, earliest due first.
class DueQueue {
  const DueQueue(this._duePolicy);

  final DuePolicy _duePolicy;

  List<DueItem> build(List<CardWithDirections> cards, DateTime now) {
    final items = [
      for (final card in cards)
        for (final direction in card.directions)
          if (_duePolicy.isDueToday(
            direction,
            cardSuspended: card.card.suspended,
            now: now,
          ))
            DueItem(card: card, direction: direction),
    ];
    items.sort(
      (first, second) =>
          first.direction.dueAt!.compareTo(second.direction.dueAt!),
    );
    return items;
  }
}
