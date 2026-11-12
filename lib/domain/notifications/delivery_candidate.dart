import '../cards/card_direction.dart';
import '../presets/preset.dart';

/// A scheduled direction of a card that is not suspended, with the preset
/// deciding how it is notified.
class DeliveryCandidate {
  const DeliveryCandidate({
    required this.direction,
    required this.preset,
    required this.groupId,
  });

  final CardDirection direction;
  final Preset preset;

  /// `null` for a card outside any group.
  final int? groupId;
}
