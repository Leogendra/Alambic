/// A button pressed on a review notification.
enum NotificationAction {
  correct,
  again,

  /// Shows the answer in place of the card, recording nothing.
  reveal,

  /// Asks the card again in place of its answer, recording nothing.
  hide,

  /// Answer typed in the field of the notification.
  answer,

  /// "OK" under the verdict of a typed answer on a chained card: moves on
  /// to the next one.
  acknowledge,

  /// "Start here" on a grouped reminder: chains its cards in the
  /// notification.
  start,

  /// "Open the app" on a grouped reminder or on the digest: opens a session,
  /// like touching the notification.
  open,
}
