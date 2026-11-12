import '../../data/repositories/card_with_directions.dart';
import '../../domain/notifications/delivery_candidate.dart';
import '../../domain/presets/preset_catalog.dart';

/// The scheduled directions of the [cards] that are not suspended, with
/// their preset: what the delivery planning works on.
List<DeliveryCandidate> deliveryCandidates(
  Iterable<CardWithDirections> cards,
  PresetCatalog catalog,
) => [
  for (final card in cards)
    if (!card.card.suspended)
      for (final direction in card.directions)
        if (direction.isScheduled)
          DeliveryCandidate(
            direction: direction,
            preset: catalog.presetForCard(card.card),
            groupId: card.card.groupId,
          ),
];
