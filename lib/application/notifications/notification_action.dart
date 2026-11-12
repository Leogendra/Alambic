/// A button pressed on a review notification.
enum NotificationAction {
  correct,
  again,

  /// Answer typed in the field of the notification.
  answer,

  /// "OK" under a revealed answer.
  acknowledge,
}
