import '../../domain/cards/flashcard.dart';
import '../../domain/scheduling/due_policy.dart';
import 'due_item.dart';

/// Builds the list of cards to review now, earliest due first.
class DueQueue {
  const DueQueue(this._duePolicy);

  final DuePolicy _duePolicy;

  List<DueItem> build(List<Flashcard> cards, DateTime now) => [
    for (final card in cards)
      if (_duePolicy.isDueToday(card, now: now)) DueItem(card),
  ]..sort((first, second) => first.card.dueAt!.compareTo(second.card.dueAt!));
}
