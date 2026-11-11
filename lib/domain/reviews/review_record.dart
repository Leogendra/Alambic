import 'review_outcome.dart';
import 'review_source.dart';

/// One answer in the history of a direction.
class ReviewRecord {
  const ReviewRecord({
    required this.id,
    required this.directionId,
    required this.reviewedAt,
    required this.outcome,
    required this.isBonus,
    required this.stepBefore,
    required this.stepAfter,
    required this.source,
  });

  final int id;
  final int directionId;
  final DateTime reviewedAt;
  final ReviewOutcome outcome;

  /// A bonus review (card not due) is kept in the history but changes nothing.
  final bool isBonus;
  final int? stepBefore;

  /// Step reached after the answer; `null` when the direction became acquired
  /// or for a bonus review.
  final int? stepAfter;
  final ReviewSource source;
}
