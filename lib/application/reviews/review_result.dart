import '../../domain/scheduling/card_schedule.dart';

/// What an answer changed, to tell the user ("missed, due tomorrow").
class ReviewResult {
  const ReviewResult({required this.isBonus, required this.schedule});

  /// A bonus answer changed nothing but the history.
  final bool isBonus;

  /// New schedule of the card; `null` for a bonus answer.
  final CardSchedule? schedule;
}
