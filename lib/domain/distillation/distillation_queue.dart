import '../cards/card_direction.dart';
import '../cards/direction_state.dart';

/// The queue of a distillation: its pending directions, by rank.
abstract final class DistillationQueue {
  /// The [count] next directions to introduce. A direction without a rank
  /// (a reverse waiting for its front) or of a suspended card is skipped and
  /// keeps its place.
  static List<CardDirection> next(
    Iterable<CardDirection> queued, {
    required Set<int> suspendedCardIds,
    required int count,
  }) =>
      (queued
              .where(
                (direction) =>
                    direction.state == DirectionState.pending &&
                    direction.queuePosition != null &&
                    !suspendedCardIds.contains(direction.cardId),
              )
              .toList()
            ..sort(
              (first, second) =>
                  first.queuePosition!.compareTo(second.queuePosition!),
            ))
          .take(count)
          .toList();

  /// Directions still waiting in the queue, ranked or not.
  static int remaining(Iterable<CardDirection> distilled) => distilled
      .where((direction) => direction.state == DirectionState.pending)
      .length;

  /// Rank after the last one of the queue.
  static int endPosition(Iterable<CardDirection> distilled) {
    var end = 0;
    for (final direction in distilled) {
      final position = direction.queuePosition;
      if (position != null && position >= end) {
        end = position + 1;
      }
    }
    return end;
  }
}
