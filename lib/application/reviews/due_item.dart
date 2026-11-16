import '../../domain/cards/flashcard.dart';

/// A card to review now.
class DueItem {
  const DueItem(this.card);

  final Flashcard card;

  int get groupId => card.groupId;
}
