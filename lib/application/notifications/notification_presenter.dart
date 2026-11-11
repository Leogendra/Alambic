import 'answer_reveal.dart';
import 'review_notification_key.dart';
import 'review_prompt.dart';

/// Shows review notifications. Implemented per platform: the application
/// decides what to show, the implementation decides how.
abstract interface class NotificationPresenter {
  /// Asks the user for the right to post notifications, where needed.
  Future<void> requestPermission();

  /// Shows a card with its "Correct" and "Again" buttons.
  Future<void> showPrompt(ReviewPrompt prompt);

  /// Replaces the notification of [reveal]'s key with the expected answer
  /// and an "OK" button.
  Future<void> showReveal(AnswerReveal reveal);

  Future<void> dismiss(ReviewNotificationKey key);

  /// Keys of the card notifications currently shown and not answered yet.
  Future<List<ReviewNotificationKey>> shownPrompts();
}
