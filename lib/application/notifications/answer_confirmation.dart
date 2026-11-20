import '../../domain/reviews/review_outcome.dart';
import '../../domain/scheduling/card_schedule.dart';
import 'review_notification_key.dart';

/// Content of a notification updated after "Correct" or "Again": the answer
/// and what it did to the schedule, nothing else.
class AnswerConfirmation {
  const AnswerConfirmation({
    required this.key,
    required this.outcome,
    required this.schedule,
    required this.answeredAt,
  });

  final ReviewNotificationKey key;
  final ReviewOutcome outcome;
  final CardSchedule schedule;
  final DateTime answeredAt;
}
