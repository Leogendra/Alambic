import 'direction_sense.dart';
import 'direction_state.dart';

/// Scheduling state of one direction of a card.
class CardDirection {
  const CardDirection({
    required this.id,
    required this.cardId,
    required this.sense,
    required this.state,
    required this.step,
    required this.dueAt,
    required this.lastReviewedAt,
    required this.notifiedAt,
  });

  final int id;
  final int cardId;
  final DirectionSense sense;
  final DirectionState state;

  /// Index, in the preset sequence, of the interval currently waited.
  /// `null` while the direction has never been answered.
  final int? step;

  /// `null` unless the direction is [DirectionState.active].
  final DateTime? dueAt;
  final DateTime? lastReviewedAt;

  /// When a notification was last shown for the current due date.
  final DateTime? notifiedAt;

  bool get isScheduled => state == DirectionState.active && dueAt != null;
}
