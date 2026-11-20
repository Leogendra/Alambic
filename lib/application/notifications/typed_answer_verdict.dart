import '../../domain/cards/card_side.dart';
import '../../domain/reviews/typed_answer_match.dart';
import '../reviews/review_result.dart';
import 'review_notification_key.dart';

/// Content of a notification updated after a typed answer: the card and its
/// group, the expected answer, how the typed answer compared with it, and
/// what the answer did to the schedule.
class TypedAnswerVerdict {
  const TypedAnswerVerdict({
    required this.key,
    required this.askedSide,
    required this.groupName,
    required this.prompt,
    required this.answer,
    required this.answerImage,
    required this.typed,
    required this.match,
    required this.result,
    required this.answeredAt,
  });

  final ReviewNotificationKey key;

  /// Face asked by the notification.
  final CardSide askedSide;
  final String groupName;
  final String prompt;
  final String answer;

  /// Image of the answer face, by its name in the image store.
  final String? answerImage;
  final String typed;
  final TypedAnswerMatch match;
  final ReviewResult result;
  final DateTime answeredAt;
}
