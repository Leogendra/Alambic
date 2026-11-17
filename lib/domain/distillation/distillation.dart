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
    required this.avoidCollisions,
    required this.status,
    required this.startedAt,
    required this.nextBatchDay,
    required this.introducedInBatch,
    required this.lastAdvancedDay,
  });

  final int groupId;
  final int cardsPerBatch;
  final int everyDays;
  final bool avoidCollisions;
  final DistillationStatus status;
  final DateTime startedAt;

  /// Scheduling day from which the current batch may be introduced.
  final DateTime nextBatchDay;

  /// Cards of the current batch already introduced; the rest of the batch
  /// comes the next days when the budget held it back or the queue was
  /// empty.
  final int introducedInBatch;

  /// Last scheduling day on which the distillation introduced its cards and
  /// spent its budget; each day is processed once.
  final DateTime? lastAdvancedDay;

  bool get isRunning => status == DistillationStatus.running;

  DistillationSettings get settings => DistillationSettings(
    cardsPerBatch: cardsPerBatch,
    everyDays: everyDays,
    avoidCollisions: avoidCollisions,
  );
}
