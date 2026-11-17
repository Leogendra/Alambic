import 'group_reminder.dart';
import 'group_reminder_key.dart';
import 'notification_digest.dart';
import 'review_notification_key.dart';
import 'review_prompt.dart';
import 'typed_answer_verdict.dart';

/// Shows review notifications. Implemented per platform: the application
/// decides what to show, the implementation decides how.
abstract interface class NotificationPresenter {
  /// Asks the user for the right to post notifications, where needed, and
  /// returns whether the app may post them.
  Future<bool> requestPermission();

  /// Shows a card with its "Correct", "Again" and "Reveal" buttons, or
  /// "Again", "Reveal" and "Answer" for a typed answer. A revealed card
  /// replaces the notification silently, with the answer and "Correct" and
  /// "Again".
  Future<void> showPrompt(ReviewPrompt prompt);

  /// Replaces the notification of [verdict]'s key with the verdict of a
  /// typed answer, the expected answer and an "OK" button.
  Future<void> showVerdict(TypedAnswerVerdict verdict);

  Future<void> dismiss(ReviewNotificationKey key);

  /// Keys of the card notifications currently shown and not answered yet,
  /// chained cards included.
  Future<List<ReviewNotificationKey>> shownPrompts();

  /// Shows the grouped reminder of a group, replacing whatever its
  /// notification shows.
  Future<void> showGroupReminder(GroupReminder reminder);

  /// Closes the notification of a grouped reminder, whatever it shows.
  Future<void> dismissGroupReminder(GroupReminderKey key);

  /// Count shown by each grouped reminder currently on screen, not chaining
  /// a card.
  Future<Map<GroupReminderKey, int>> shownGroupReminders();

  /// Shows the notification gathering the cards of a moment beyond the auto
  /// grouping threshold; there is only one, replaced each time.
  Future<void> showDigest(NotificationDigest digest);

  Future<void> dismissDigest();

  /// Count shown by the digest, `null` when it is not on screen.
  Future<int?> shownDigestCount();
}
