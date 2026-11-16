import '../cards/flashcard.dart';
import '../presets/preset.dart';

/// A scheduled card that is not suspended, with the preset deciding how it
/// is notified.
class DeliveryCandidate {
  const DeliveryCandidate({required this.card, required this.preset});

  final Flashcard card;
  final Preset preset;

  int get groupId => card.groupId;
}
