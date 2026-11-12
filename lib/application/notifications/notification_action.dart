/// A button pressed on a review notification.
enum NotificationAction {
  correct,
  again,

  /// Answer typed in the field of the notification.
  answer,

  /// "OK" under a revealed answer.
  acknowledge,

  /// "Start here" on a grouped reminder: chains its cards in the
  /// notification.
  start,

  /// "Open" on a grouped reminder or a chained card: opens the app on the
  /// group.
  open,
}
