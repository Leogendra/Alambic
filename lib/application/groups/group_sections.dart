import '../../domain/cards/card_state.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/distillation/distillation_queue.dart';

/// The cards of a group page, in its three sections: the introduced ones,
/// soonest first with the suspended ones at the end, the queue in its order,
/// and the acquired ones.
class GroupSections {
  factory GroupSections.of(Iterable<Flashcard> groupCards) {
    final ongoing = [
      for (final card in groupCards)
        if (card.state == CardState.active || card.state == CardState.remanent)
          card,
    ]..sort(_bySoonest);
    return GroupSections._(
      ongoing: ongoing,
      waiting: DistillationQueue.inOrder(groupCards),
      acquired: [
        for (final card in groupCards)
          if (card.state == CardState.acquired) card,
      ],
    );
  }

  const GroupSections._({
    required this.ongoing,
    required this.waiting,
    required this.acquired,
  });

  final List<Flashcard> ongoing;
  final List<Flashcard> waiting;
  final List<Flashcard> acquired;

  bool get isEmpty => ongoing.isEmpty && waiting.isEmpty && acquired.isEmpty;

  /// The card the distillation brings out next: the first of the queue that
  /// is not suspended.
  int? get nextId => DistillationQueue.next(waiting, 1).firstOrNull?.id;

  static int _bySoonest(Flashcard first, Flashcard second) {
    if (first.suspended != second.suspended) {
      return first.suspended ? 1 : -1;
    }
    final byDue = (first.dueAt ?? DateTime(0)).compareTo(
      second.dueAt ?? DateTime(0),
    );
    return byDue != 0 ? byDue : first.id.compareTo(second.id);
  }
}
