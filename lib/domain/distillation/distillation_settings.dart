/// What the user picks when activating or adjusting a distillation.
class DistillationSettings {
  const DistillationSettings({
    this.cardsPerBatch = 1,
    this.prioritizeReviews = true,
  }) : assert(cardsPerBatch > 0);

  /// N in "N cards a day".
  final int cardsPerBatch;

  /// On a batch day, each card of the group due for review takes the place
  /// of a new card.
  final bool prioritizeReviews;

  DistillationSettings copyWith({
    int? cardsPerBatch,
    bool? prioritizeReviews,
  }) => DistillationSettings(
    cardsPerBatch: cardsPerBatch ?? this.cardsPerBatch,
    prioritizeReviews: prioritizeReviews ?? this.prioritizeReviews,
  );
}
