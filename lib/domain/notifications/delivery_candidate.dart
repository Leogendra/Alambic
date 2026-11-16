import '../cards/flashcard.dart';
import '../presets/preset.dart';

/// A scheduled card that is not suspended, with the preset ranking its
/// interval against the daily cap.
class DeliveryCandidate {
  const DeliveryCandidate({required this.card, required this.preset});

  final Flashcard card;
  final Preset preset;

  int get groupId => card.groupId;
}
