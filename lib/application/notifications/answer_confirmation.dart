import '../../domain/scheduling/card_schedule.dart';
import 'review_notification_key.dart';

/// Content of a notification updated after "Correct" or "Again": what the
/// answer did to the schedule, nothing else.
class AnswerConfirmation {
  const AnswerConfirmation({
    required this.key,
    required this.schedule,
    required this.answeredAt,
  });

  final ReviewNotificationKey key;
  final CardSchedule schedule;
  final DateTime answeredAt;
}
