import '../cards/card_state.dart';
import 'review_outcome.dart';
import 'review_source.dart';

/// One answer in the history of a card.
class ReviewRecord {
  const ReviewRecord({
    required this.id,
    required this.cardId,
    required this.reviewedAt,
    required this.outcome,
    required this.isBonus,
    required this.stepBefore,
    required this.stepAfter,
    required this.stateAfter,
    required this.dueAtAfter,
    required this.source,
  });

  final int id;
  final int cardId;
  final DateTime reviewedAt;
  final ReviewOutcome outcome;

  /// A bonus review (card not due) is kept in the history but changes nothing.
  final bool isBonus;
  final int? stepBefore;

  /// Step reached after the answer; `null` outside the sequence (remanent or
  /// acquired) and for a bonus review.
  final int? stepAfter;

  /// State the answer gave the card; `null` for a bonus review.
  final CardState? stateAfter;

  /// Due date the answer gave; `null` for a bonus review and once acquired.
  final DateTime? dueAtAfter;
  final ReviewSource source;
}
