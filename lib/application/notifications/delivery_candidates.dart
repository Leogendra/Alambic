import '../../domain/cards/flashcard.dart';
import '../../domain/notifications/delivery_candidate.dart';
import '../../domain/pauses/pauses.dart';
import '../../domain/presets/preset_catalog.dart';

/// The scheduled [cards] that are neither suspended nor paused, with their
/// preset: what the delivery planning works on.
List<DeliveryCandidate> deliveryCandidates(
  Iterable<Flashcard> cards,
  PresetCatalog catalog,
  Pauses pauses,
) => [
  for (final card in cards)
    if (!card.suspended && !pauses.covers(card.groupId) && card.isScheduled)
      DeliveryCandidate(card: card, preset: catalog.presetForCard(card)),
];
