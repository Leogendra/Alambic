/// What a group does with a card once the last step of its preset is passed.
enum AfterLastStep {
  /// The card comes back forever, at the remanence interval of the group.
  remanence,

  /// The card is acquired: no more reminder.
  acquired,
}
