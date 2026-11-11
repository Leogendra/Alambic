import '../../domain/reviews/review_outcome.dart';
import 'session_item.dart';

/// Progress of an in-app review session: which card comes next and what was
/// answered. Bonus sessions (reviewing missed cards again) change nothing in
/// the schedule.
class ReviewSession {
  ReviewSession({
    required List<SessionItem> items,
    required this.isBonus,
    required this.startedAt,
  }) : items = List.unmodifiable(items);

  final List<SessionItem> items;
  final bool isBonus;
  final DateTime startedAt;
  final List<ReviewOutcome> _outcomes = [];

  int get position => _outcomes.length;

  bool get isFinished => position >= items.length;

  SessionItem? get current => isFinished ? null : items[position];

  int get correctCount =>
      _outcomes.where((outcome) => outcome == ReviewOutcome.correct).length;

  int get againCount =>
      _outcomes.where((outcome) => outcome == ReviewOutcome.again).length;

  /// Items answered "Again", to review them again as a bonus.
  List<SessionItem> get missedItems => [
    for (var index = 0; index < _outcomes.length; index++)
      if (_outcomes[index] == ReviewOutcome.again) items[index],
  ];

  /// Records the answer to the current item and moves to the next one.
  void record(ReviewOutcome outcome) {
    if (isFinished) {
      throw StateError('The session is finished.');
    }
    _outcomes.add(outcome);
  }
}
