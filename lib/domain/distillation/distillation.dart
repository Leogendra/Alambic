import '../cards/direction_sense.dart';
import 'distillation_order.dart';
import 'distillation_settings.dart';
import 'distillation_status.dart';

/// Introduces the never reviewed directions of a group, or of every card for
/// the global distillation, a few at a time. Its queue is made of the
/// directions in the pending state that point to it.
class Distillation {
  const Distillation({
    required this.id,
    required this.groupId,
    required this.sense,
    required this.cardsPerBatch,
    required this.everyDays,
    required this.introductionOrder,
    required this.avoidCollisions,
    required this.status,
    required this.startedAt,
    required this.nextBatchDay,
    required this.introducedInBatch,
    required this.lastAdvancedDay,
  });

  final int id;

  /// `null` for the global distillation.
  final int? groupId;

  /// Direction distilled; `null` for the global distillation, which covers
  /// both.
  final DirectionSense? sense;
  final int cardsPerBatch;
  final int everyDays;
  final DistillationOrder introductionOrder;
  final bool avoidCollisions;
  final DistillationStatus status;
  final DateTime startedAt;

  /// Scheduling day from which the current batch may be introduced.
  final DateTime nextBatchDay;

  /// Cards of the current batch already introduced; the rest of the batch
  /// comes the next days when the budget held it back.
  final int introducedInBatch;

  /// Last scheduling day on which the distillation introduced its cards and
  /// spent its budget; each day is processed once.
  final DateTime? lastAdvancedDay;

  bool get isGlobal => groupId == null;

  bool get isRunning => status == DistillationStatus.running;

  DistillationSettings get settings => DistillationSettings(
    cardsPerBatch: cardsPerBatch,
    everyDays: everyDays,
    order: introductionOrder,
    avoidCollisions: avoidCollisions,
  );
}
