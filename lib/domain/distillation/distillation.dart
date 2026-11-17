import 'distillation_settings.dart';
import 'distillation_status.dart';

/// The distillation of a group: a permanent setting of the group that
/// introduces its pending cards a few at a time. Its queue is made of the
/// pending cards of the group. It exists once activated, and is only ever
/// paused or resumed afterwards.
class Distillation {
  const Distillation({
    required this.groupId,
    required this.cardsPerBatch,
    required this.everyDays,
    required this.prioritizeReviews,
    required this.status,
    required this.startedAt,
    required this.lastBatchDay,
    required this.lastAdvancedDay,
  });

  final int groupId;
  final int cardsPerBatch;
  final int everyDays;
  final bool prioritizeReviews;
  final DistillationStatus status;
  final DateTime startedAt;

  /// Last scheduling day on which a batch came out; the next one comes X
  /// days later. `null` until the first batch.
  final DateTime? lastBatchDay;

  /// Last scheduling day the daily pass processed; each day is processed
  /// once.
  final DateTime? lastAdvancedDay;

  bool get isRunning => status == DistillationStatus.running;

  DistillationSettings get settings => DistillationSettings(
    cardsPerBatch: cardsPerBatch,
    everyDays: everyDays,
    prioritizeReviews: prioritizeReviews,
  );
}
