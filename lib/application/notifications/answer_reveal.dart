import '../../domain/reviews/typed_answer_match.dart';
import '../reviews/review_result.dart';
import 'review_notification_key.dart';

/// Content of a notification updated after "Again" or a typed answer: the
/// expected answer, how the typed answer compared with it, and what the
/// answer did to the schedule.
class AnswerReveal {
  const AnswerReveal({
    required this.key,
    required this.prompt,
    required this.answer,
    required this.result,
    required this.answeredAt,
    this.typed,
    this.match,
  });

  final ReviewNotificationKey key;
  final String prompt;
  final String answer;
  final ReviewResult result;
  final DateTime answeredAt;

  /// The typed answer and its comparison; `null` after the "Again" button.
  final String? typed;
  final TypedAnswerMatch? match;
}
