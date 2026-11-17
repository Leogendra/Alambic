/// Lifecycle of a card.
enum CardState {
  /// Waiting in the queue of its group, until the distillation of the group
  /// introduces it. Never due by itself.
  pending,

  /// Walking the sequence of its preset: it has a step and a due date.
  active,

  /// Past the last step of its preset, coming back forever at the remanence
  /// interval of its group. It has a due date but no step: a remanence kept
  /// as a state, rather than as a step past the sequence, stays a remanence
  /// whatever the length of the sequence it follows.
  remanent,

  /// Past the last step, in a group whose cards are then acquired: no more
  /// reminder.
  acquired,
}
