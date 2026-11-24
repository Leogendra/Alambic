import 'dart:math';

import '../../data/repositories/card_repository.dart';
import '../../domain/cards/flashcard.dart';
import '../../domain/distillation/distillation_queue.dart';
import '../scheduling/schedule_change_listener.dart';

/// Reorders the queue of a group by hand. Each move writes the ranks of the
/// whole queue again, from 0, so that the order stored is the order shown.
class QueueService {
  const QueueService({
    required this._cards,
    required this._scheduleChangeListener,
  });

  final CardRepository _cards;
  final ScheduleChangeListener _scheduleChangeListener;

  /// The card comes out next.
  Future<void> moveToHead(int cardId) => moveTo(cardId, 0);

  /// The card comes out last.
  Future<void> moveToEnd(int cardId) => _move(cardId, (queue) => queue.length);

  /// The card takes [index] in the queue (0 for its head), the others
  /// keeping their order around it.
  Future<void> moveTo(int cardId, int index) => _move(cardId, (_) => index);

  /// Draws a new order for the whole queue of [groupId].
  Future<void> shuffleQueue(int groupId, Random random) =>
      _reorder(groupId, (queue) => queue..shuffle(random));

  Future<void> _move(
    int cardId,
    int Function(List<Flashcard> others) index,
  ) async {
    final card = await _cards.getCard(cardId);
    if (!card.isPending) {
      throw ArgumentError.value(cardId, 'cardId', 'is not in a queue');
    }
    await _reorder(card.groupId, (queue) {
      queue.removeWhere((other) => other.id == cardId);
      return queue..insert(index(queue).clamp(0, queue.length), card);
    });
  }

  Future<void> _reorder(
    int groupId,
    List<Flashcard> Function(List<Flashcard> queue) reorder,
  ) async {
    await _cards.transaction(() async {
      final queue = reorder(
        DistillationQueue.inOrder(await _cards.getCardsOfGroup(groupId)),
      );
      for (final (position, card) in queue.indexed) {
        if (card.queuePosition != position) {
          await _cards.setQueuePosition(card.id, position);
        }
      }
    });
    await _scheduleChangeListener.onSchedulesChanged();
  }
}
