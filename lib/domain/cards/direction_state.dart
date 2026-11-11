/// Lifecycle of a direction.
enum DirectionState {
  /// Not studied (for example the reverse of a card created one-way).
  inactive,

  /// Waiting in the queue of a distillation.
  pending,

  /// Scheduled: it has a due date.
  active,

  /// The preset stopped the sequence after its last step.
  acquired,
}
