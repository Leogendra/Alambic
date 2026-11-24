import '../../domain/cards/flashcard.dart';
import '../../domain/scheduling/due_policy.dart';

/// Orders the cards of a group for "Review all": the cards due today first,
/// earliest due first, then the other introduced cards, soonest due first,
/// then the pending ones in queue order. The acquired cards are left out,
/// done with for good.
class WholeGroupReview {
  const WholeGroupReview(this._duePolicy);

  final DuePolicy _duePolicy;

  List<int> cardIds(List<Flashcard> groupCards, DateTime now) {
    final due = <Flashcard>[];
    final introduced = <Flashcard>[];
    final pending = <Flashcard>[];
    for (final card in groupCards.where((card) => !card.isAcquired)) {
      if (_duePolicy.isDueToday(card, now: now)) {
        due.add(card);
      } else if (card.isPending) {
        pending.add(card);
      } else {
        introduced.add(card);
      }
    }
    due.sort(_byDueAt);
    introduced.sort(_byDueAt);
    pending.sort(_byQueuePosition);
    return [
      for (final card in [...due, ...introduced, ...pending]) card.id,
    ];
  }

  /// Cards due at the same moment keep their creation order.
  static int _byDueAt(Flashcard first, Flashcard second) {
    final order = _nullsLast(first.dueAt, second.dueAt);
    if (order != 0) {
      return order;
    } else {
      return first.id.compareTo(second.id);
    }
  }

  static int _byQueuePosition(Flashcard first, Flashcard second) =>
      _nullsLast(first.queuePosition, second.queuePosition);

  static int _nullsLast<T extends Comparable<Object>>(T? first, T? second) {
    if (first == null && second == null) {
      return 0;
    } else if (first == null) {
      return 1;
    } else if (second == null) {
      return -1;
    } else {
      return first.compareTo(second);
    }
  }
}
