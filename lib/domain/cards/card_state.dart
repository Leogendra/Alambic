/// Lifecycle of a card.
enum CardState {
  /// Waiting in the queue of its group, until the distillation of the group
  /// introduces it. Never due by itself.
  pending,

  /// Walking the sequence of its preset: it has a step and a due date.
  active,

  /// Past the last step of its preset, without step. Its group decides
  /// whether it comes back: in remanence it has a due date, acquired it has
  /// none. Kept as a state rather than as a step past the sequence, it stays
  /// past the sequence whatever the length of the sequence it follows.
  completed,
}
