import 'distillation_order.dart';

/// What the user picks when launching a distillation.
class DistillationSettings {
  const DistillationSettings({
    this.cardsPerBatch = 1,
    this.everyDays = 1,
    this.order = DistillationOrder.groupOrder,
    this.avoidCollisions = true,
  }) : assert(cardsPerBatch > 0),
       assert(everyDays > 0);

  /// N in "N cards every X days".
  final int cardsPerBatch;

  /// X in "N cards every X days".
  final int everyDays;
  final DistillationOrder order;

  /// Gives the distillation a daily budget of [cardsPerBatch] notifications,
  /// spent on its reminders first.
  final bool avoidCollisions;

  DistillationSettings copyWith({
    int? cardsPerBatch,
    int? everyDays,
    DistillationOrder? order,
    bool? avoidCollisions,
  }) => DistillationSettings(
    cardsPerBatch: cardsPerBatch ?? this.cardsPerBatch,
    everyDays: everyDays ?? this.everyDays,
    order: order ?? this.order,
    avoidCollisions: avoidCollisions ?? this.avoidCollisions,
  );
}
