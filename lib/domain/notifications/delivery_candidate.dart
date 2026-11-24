import '../cards/flashcard.dart';
import '../scheduling/card_progress.dart';

/// A scheduled card, with where it stands in its sequence, which ranks its
/// interval against the daily cap.
class DeliveryCandidate {
  const DeliveryCandidate({required this.card, required this.progress});

  final Flashcard card;
  final CardProgress progress;

  int get groupId => card.groupId;
}
