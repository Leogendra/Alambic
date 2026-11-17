/// A button pressed on a review notification.
enum NotificationAction {
  correct,
  again,

  /// Shows the answer in place of the card, recording nothing.
  reveal,

  /// Answer typed in the field of the notification.
  answer,

  /// "OK" under the verdict of a typed answer.
  acknowledge,

  /// "Start here" on a grouped reminder: chains its cards in the
  /// notification.
  start,

  /// "Open the app" on a grouped reminder or on the digest.
  open,
}
