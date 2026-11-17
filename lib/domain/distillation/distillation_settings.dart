/// What the user picks when activating or adjusting a distillation.
class DistillationSettings {
  const DistillationSettings({
    this.cardsPerBatch = 1,
    this.everyDays = 1,
    this.avoidCollisions = true,
  }) : assert(cardsPerBatch > 0),
       assert(everyDays > 0);

  /// N in "N cards every X days".
  final int cardsPerBatch;

  /// X in "N cards every X days".
  final int everyDays;

  /// Gives the distillation a daily budget of [cardsPerBatch] notifications,
  /// spent on its reminders first.
  final bool avoidCollisions;

  DistillationSettings copyWith({
    int? cardsPerBatch,
    int? everyDays,
    bool? avoidCollisions,
  }) => DistillationSettings(
    cardsPerBatch: cardsPerBatch ?? this.cardsPerBatch,
    everyDays: everyDays ?? this.everyDays,
    avoidCollisions: avoidCollisions ?? this.avoidCollisions,
  );
}
