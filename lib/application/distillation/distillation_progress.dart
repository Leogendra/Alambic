import '../../domain/cards/flashcard.dart';
import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_queue.dart';
import '../../domain/distillation/distillation_rhythm.dart';

/// Where the distillation of a group stands, as shown on its page and on
/// Home.
class DistillationProgress {
  const DistillationProgress({
    required this.distillation,
    required this.remaining,
    required this.lastArrival,
  });

  /// Counts the waiting cards of the group of [distillation] among
  /// [groupCards] and estimates the last arrival of its queue seen from
  /// [today]; no arrival is planned while it or every distillation
  /// ([globallyPaused]) is paused.
  factory DistillationProgress.of(
    Distillation distillation,
    List<Flashcard> groupCards,
    DistillationRhythm rhythm,
    DateTime today, {
    required bool globallyPaused,
  }) {
    final remaining = DistillationQueue.remaining(groupCards);
    return DistillationProgress(
      distillation: distillation,
      remaining: remaining,
      lastArrival: !distillation.isPaused && !globallyPaused
          ? rhythm.lastArrival(
              remaining: remaining,
              cardsPerBatch: distillation.cardsPerBatch,
              everyDays: distillation.everyDays,
              firstDay: rhythm.nextIntroductionDay(distillation, today),
            )
          : null,
    );
  }

  final Distillation distillation;

  /// Cards still in the queue.
  final int remaining;

  /// Day the last card of the queue should arrive if no reminder holds a
  /// batch back; `null` while paused, during the global pause or when the
  /// queue is empty.
  final DateTime? lastArrival;

  int get groupId => distillation.groupId;
}
