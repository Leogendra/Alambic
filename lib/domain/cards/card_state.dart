/// Lifecycle of a card.
enum CardState {
  /// Waiting in the queue of its group, until the distillation of the group
  /// introduces it. Never due by itself.
  pending,

  /// Scheduled: it has a due date.
  active,

  /// The preset stopped the sequence after its last step.
  acquired,
}
