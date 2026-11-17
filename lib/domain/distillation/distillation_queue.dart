import '../cards/flashcard.dart';

/// The queue of a group: its pending cards, by rank.
abstract final class DistillationQueue {
  /// The [count] next cards of [groupCards] to introduce. A suspended card is
  /// skipped and keeps its place.
  static List<Flashcard> next(Iterable<Flashcard> groupCards, int count) =>
      (groupCards.where((card) => card.isPending && !card.suspended).toList()
            ..sort(_byRank))
          .take(count)
          .toList();

  /// Cards still waiting in the queue, suspended ones included.
  static int remaining(Iterable<Flashcard> groupCards) =>
      groupCards.where((card) => card.isPending).length;

  /// Rank after the last one of the queue: where a card joining it goes.
  static int endPosition(Iterable<Flashcard> groupCards) {
    var end = 0;
    for (final card in groupCards) {
      final position = card.queuePosition;
      if (card.isPending && position != null && position >= end) {
        end = position + 1;
      }
    }
    return end;
  }

  static int _byRank(Flashcard first, Flashcard second) {
    final byPosition = (first.queuePosition ?? 0).compareTo(
      second.queuePosition ?? 0,
    );
    return byPosition != 0 ? byPosition : first.id.compareTo(second.id);
  }
}
