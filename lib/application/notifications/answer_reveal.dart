import '../reviews/review_result.dart';
import 'review_notification_key.dart';

/// Content of a notification updated after "Again": the expected answer and
/// what the answer did to the schedule.
class AnswerReveal {
  const AnswerReveal({
    required this.key,
    required this.prompt,
    required this.answer,
    required this.result,
    required this.answeredAt,
  });

  final ReviewNotificationKey key;
  final String prompt;
  final String answer;
  final ReviewResult result;
  final DateTime answeredAt;
}
