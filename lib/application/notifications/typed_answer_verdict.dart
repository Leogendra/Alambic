import '../../domain/reviews/typed_answer_match.dart';
import '../reviews/review_result.dart';
import 'review_notification_key.dart';

/// Content of a notification updated after a typed answer: whether it was
/// accepted, the expected answer, and what the answer did to the schedule.
class TypedAnswerVerdict {
  const TypedAnswerVerdict({
    required this.key,
    required this.answer,
    required this.match,
    required this.result,
    required this.answeredAt,
  });

  final ReviewNotificationKey key;

  /// The expected answer, shown when the typed one is refused.
  final String answer;
  final TypedAnswerMatch match;
  final ReviewResult result;
  final DateTime answeredAt;
}
