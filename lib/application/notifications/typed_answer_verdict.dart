import '../../domain/reviews/typed_answer_match.dart';
import '../reviews/review_result.dart';
import 'review_notification_key.dart';

/// Content of a notification updated after a typed answer: whether it was
/// accepted, what the answer did to the schedule, and the expected answer.
class TypedAnswerVerdict {
  const TypedAnswerVerdict({
    required this.key,
    required this.groupName,
    required this.answer,
    required this.answerImage,
    required this.match,
    required this.result,
    required this.answeredAt,
  });

  final ReviewNotificationKey key;
  final String groupName;

  /// The expected answer, shown whether the typed one is accepted or not.
  final String answer;

  /// Image of the expected answer, by its name in the image store.
  final String? answerImage;
  final TypedAnswerMatch match;
  final ReviewResult result;
  final DateTime answeredAt;
}
