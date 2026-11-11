/// Lifecycle of a direction.
enum DirectionState {
  /// Not studied (for example the reverse of a card created one-way).
  inactive,

  /// Studied but not started yet: a new card waits for the user to choose how
  /// it enters review, all at once or through a distillation.
  unstarted,

  /// Waiting in the queue of a distillation.
  pending,

  /// Scheduled: it has a due date.
  active,

  /// The preset stopped the sequence after its last step.
  acquired,
}
