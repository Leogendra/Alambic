/// What the user picks when activating or adjusting a distillation.
class DistillationSettings {
  const DistillationSettings({
    this.cardsPerBatch = 1,
    this.everyDays = 1,
    this.prioritizeReviews = true,
  }) : assert(cardsPerBatch > 0),
       assert(everyDays > 0);

  /// N in "N cards every X days".
  final int cardsPerBatch;

  /// X in "N cards every X days".
  final int everyDays;

  /// On a batch day, each card of the group due for review takes the place
  /// of a new card.
  final bool prioritizeReviews;

  DistillationSettings copyWith({
    int? cardsPerBatch,
    int? everyDays,
    bool? prioritizeReviews,
  }) => DistillationSettings(
    cardsPerBatch: cardsPerBatch ?? this.cardsPerBatch,
    everyDays: everyDays ?? this.everyDays,
    prioritizeReviews: prioritizeReviews ?? this.prioritizeReviews,
  );
}
