import 'review_notification_key.dart';

/// Content of a notification asking a card: the asked face and where the
/// direction stands. Formatted into text by the platform implementation.
class ReviewPrompt {
  const ReviewPrompt({
    required this.key,
    required this.prompt,
    required this.groupName,
    required this.step,
    required this.sequenceLength,
    required this.isReverse,
  });

  final ReviewNotificationKey key;

  /// Text of the asked face.
  final String prompt;

  /// `null` for a card outside any group.
  final String? groupName;

  /// Current step, `null` for a direction never answered.
  final int? step;
  final int sequenceLength;

  /// Back → front direction.
  final bool isReverse;
}
