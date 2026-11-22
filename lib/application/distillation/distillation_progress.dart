import '../../domain/cards/flashcard.dart';
import '../../domain/distillation/distillation.dart';
import '../../domain/distillation/distillation_queue.dart';

/// Where the distillation of a group stands, as shown on its page.
class DistillationProgress {
  const DistillationProgress({
    required this.distillation,
    required this.remaining,
  });

  /// Counts the waiting cards of the group of [distillation] among
  /// [groupCards].
  factory DistillationProgress.of(
    Distillation distillation,
    List<Flashcard> groupCards,
  ) => DistillationProgress(
    distillation: distillation,
    remaining: DistillationQueue.remaining(groupCards),
  );

  final Distillation distillation;

  /// Cards still in the queue.
  final int remaining;

  int get groupId => distillation.groupId;
}
