import 'distillation_settings.dart';

/// The distillation of a group: a permanent setting of the group that
/// introduces its pending cards a few at a time. Its queue is made of the
/// pending cards of the group. It exists once activated, and is only ever
/// paused or resumed afterwards: it never stops nor ends.
class Distillation {
  const Distillation({
    required this.groupId,
    required this.cardsPerBatch,
    required this.prioritizeReviews,
    required this.pausedAt,
    required this.startedAt,
    required this.lastBatchDay,
    required this.lastAdvancedDay,
  });

  final int groupId;
  final int cardsPerBatch;
  final bool prioritizeReviews;

  /// Start of the pause of the distillation, `null` while it runs. While
  /// paused, no card leaves the queue; the cards introduced go on.
  final DateTime? pausedAt;
  final DateTime startedAt;

  /// Last scheduling day on which a batch came out; the next one comes
  /// the day after. `null` until the first batch.
  final DateTime? lastBatchDay;

  /// Last scheduling day the daily pass processed; each day is processed
  /// once.
  final DateTime? lastAdvancedDay;

  bool get isPaused => pausedAt != null;

  DistillationSettings get settings => DistillationSettings(
    cardsPerBatch: cardsPerBatch,
    prioritizeReviews: prioritizeReviews,
  );

  /// This distillation adjusted to [settings].
  Distillation withSettings(DistillationSettings settings) => Distillation(
    groupId: groupId,
    cardsPerBatch: settings.cardsPerBatch,
    prioritizeReviews: settings.prioritizeReviews,
    pausedAt: pausedAt,
    startedAt: startedAt,
    lastBatchDay: lastBatchDay,
    lastAdvancedDay: lastAdvancedDay,
  );
}
