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
    required this.dueAtAfter,
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

  /// Due date the answer gave; `null` for a bonus review, once acquired, and
  /// for the answers recorded before it was stored.
  final DateTime? dueAtAfter;
  final ReviewSource source;
}
