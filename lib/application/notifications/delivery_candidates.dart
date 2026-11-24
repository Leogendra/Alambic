import '../../domain/cards/flashcard.dart';
import '../../domain/notifications/delivery_candidate.dart';
import '../../domain/presets/preset_catalog.dart';
import '../../domain/scheduling/card_progress.dart';

/// The scheduled [cards], with their progress: what the delivery planning
/// works on. A pause never removes a card from it.
List<DeliveryCandidate> deliveryCandidates(
  Iterable<Flashcard> cards,
  PresetCatalog catalog,
) => [
  for (final card in cards)
    if (card.isScheduled)
      DeliveryCandidate(
        card: card,
        progress: CardProgress.of(
          card,
          catalog.presetForGroup(card.groupId),
          catalog.sequenceEndForGroup(card.groupId),
        ),
      ),
];
