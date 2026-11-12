import '../../data/repositories/card_with_directions.dart';
import '../../domain/cards/direction_state.dart';
import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_rhythm.dart';

/// Where a distillation stands, as shown on a group page and on Home.
class DistillationProgress {
  const DistillationProgress({
    required this.distillation,
    required this.introduced,
    required this.remaining,
    required this.lastArrival,
  });

  /// Counts the directions of [distillation] among [cards] and estimates its
  /// last arrival seen from [today].
  factory DistillationProgress.of(
    Distillation distillation,
    List<CardWithDirections> cards,
    DistillationRhythm rhythm,
    DateTime today,
  ) {
    var introduced = 0;
    var remaining = 0;
    for (final card in cards) {
      for (final direction in card.directions) {
        if (direction.distillationId == distillation.id) {
          if (direction.state == DirectionState.pending) {
            remaining++;
          } else {
            introduced++;
          }
        }
      }
    }
    return DistillationProgress(
      distillation: distillation,
      introduced: introduced,
      remaining: remaining,
      lastArrival: distillation.isRunning
          ? rhythm.lastArrival(
              // The current batch already gave some of its cards.
              remaining: remaining + distillation.introducedInBatch,
              cardsPerBatch: distillation.cardsPerBatch,
              everyDays: distillation.everyDays,
              firstDay: rhythm.nextIntroductionDay(distillation, today),
            )
          : null,
    );
  }

  final Distillation distillation;

  /// Directions it has introduced so far.
  final int introduced;

  /// Directions still in its queue.
  final int remaining;

  /// Day the last card should arrive if no reminder holds a batch back;
  /// `null` while paused or when nothing remains.
  final DateTime? lastArrival;

  int get total => introduced + remaining;
}
