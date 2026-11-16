import 'dart:math';

import '../../data/repositories/card_repository.dart';
import '../../data/repositories/group_repository.dart';
import '../../domain/cards/asked_side_draw.dart';
import 'session_item.dart';

/// Prepares the cards of an in-app session, drawing the face each one asks.
/// A session opened again on the same cards draws again.
class SessionItemFactory {
  const SessionItemFactory({
    required this._cards,
    required this._groups,
    required this._random,
  });

  final CardRepository _cards;
  final GroupRepository _groups;
  final Random _random;

  /// Items of [cardIds], in their order; a card deleted meanwhile is left
  /// out.
  Future<List<SessionItem>> itemsFor(Iterable<int> cardIds) async {
    final groups = {
      for (final group in await _groups.watchAll().first) group.id: group,
    };
    return [
      for (final cardId in cardIds)
        if (await _cards.findCard(cardId) case final card?)
          SessionItem(
            cardId: card.id,
            askedSide: AskedSideDraw.draw(groups[card.groupId]!, _random),
          ),
    ];
  }
}
