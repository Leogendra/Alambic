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
  /// [now]; no arrival is planned while it or every distillation
  /// ([globallyPaused]) is paused.
  factory DistillationProgress.of(
    Distillation distillation,
    List<Flashcard> groupCards,
    DistillationRhythm rhythm,
    DateTime now, {
    required bool globallyPaused,
  }) => DistillationProgress(
    distillation: distillation,
    remaining: DistillationQueue.remaining(groupCards),
    lastArrival: !distillation.isPaused && !globallyPaused
        ? rhythm
              .forecast(
                distillation.settings,
                groupCards,
                firstDay: rhythm.nextIntroductionDay(
                  distillation,
                  rhythm.calendar.dayOf(now),
                ),
                now: now,
              )
              .keys
              .lastOrNull
        : null,
  );

  final Distillation distillation;

  /// Cards still in the queue.
  final int remaining;

  /// Day the last card of the queue should arrive, the reviews already
  /// planned taking their places; `null` while paused, during the global
  /// pause or when the queue is empty.
  final DateTime? lastArrival;

  int get groupId => distillation.groupId;
}
