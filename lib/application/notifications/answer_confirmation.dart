import '../../domain/reviews/review_outcome.dart';
import '../../domain/scheduling/card_schedule.dart';
import 'review_notification_key.dart';

/// Content of a notification updated after "Correct" or "Again": what the
/// answer did to the schedule, with the answer face of the card, revealed or
/// not.
class AnswerConfirmation {
  const AnswerConfirmation({
    required this.key,
    required this.outcome,
    required this.schedule,
    required this.answeredAt,
    required this.groupName,
    required this.answer,
    required this.answerImage,
  });

  final ReviewNotificationKey key;
  final ReviewOutcome outcome;
  final CardSchedule schedule;
  final DateTime answeredAt;
  final String groupName;

  /// Text of the answer face; empty for an image alone.
  final String answer;

  /// Image of the answer face, by its name in the image store.
  final String? answerImage;
}
