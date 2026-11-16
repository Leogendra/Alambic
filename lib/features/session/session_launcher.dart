import 'package:flutter/material.dart';

import '../../application/reviews/due_item.dart';
import '../../application/reviews/session_item.dart';
import '../../domain/cards/card_side.dart';
import 'session_screen.dart';

/// Opens a session on the due [items]; does nothing when there are none.
Future<void> startSession(BuildContext context, List<DueItem> items) async {
  if (items.isEmpty) {
    return;
  }
  await openSession(context, items.map(_toSessionItem).toList());
}

/// Opens a session on [items], due or not: answering a card that is not due
/// is a bonus review.
Future<void> openSession(BuildContext context, List<SessionItem> items) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SessionScreen(items: items),
      ),
    );

/// Replaces the current session by a new one, for "Review the missed cards".
Future<void> replaceWithSession(
  BuildContext context,
  List<SessionItem> items, {
  required bool isBonus,
}) => Navigator.of(context).pushReplacement(
  MaterialPageRoute<void>(
    builder: (context) => SessionScreen(items: items, isBonus: isBonus),
  ),
);

SessionItem _toSessionItem(DueItem item) =>
    SessionItem(cardId: item.card.id, askedSide: CardSide.front);
