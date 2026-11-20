import '../../domain/reviews/review_outcome.dart';
import 'answer_confirmation.dart';
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

  /// Shows a card with its "Again", "Reveal" and "Correct" buttons, or
  /// "Again", "Reveal" and "Answer" for a typed answer. A revealed card shows
  /// the answer with "Again", "Hide" and "Correct".
  Future<void> showPrompt(ReviewPrompt prompt);

  /// Replaces the notification of [verdict]'s key, silently, with the
  /// verdict of a typed answer and what it did ("To review (Lima), next in
  /// 1 d"). It closes by itself after a few seconds, or gives a chained card
  /// an "OK" button moving on to the next one.
  Future<void> showVerdict(TypedAnswerVerdict verdict);

  /// Replaces the notification of [confirmation]'s key, silently, with the
  /// answer and what it did ("Correct, next in 3 d"). It closes by itself
  /// after a few seconds.
  Future<void> showConfirmation(AnswerConfirmation confirmation);

  /// Shows the test notification of the onboarding, a sample card tied to
  /// no card, with the buttons of a card notification; [isRevealed] shows its
  /// answer. Without [alert], it changes in place silently.
  Future<void> showTestPrompt({bool isRevealed = false, bool alert = true});

  /// Replaces the test notification, silently, with what [outcome] would
  /// have done to a card due again at [dueAt], as [showConfirmation] does.
  Future<void> showTestConfirmation(
    ReviewOutcome outcome, {
    required DateTime dueAt,
    required DateTime answeredAt,
  });

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
