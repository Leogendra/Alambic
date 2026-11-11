import 'package:flutter/material.dart';

import '../../application/reviews/due_item.dart';
import '../../application/reviews/session_item.dart';
import 'session_screen.dart';

/// Opens a session on the due [items]; does nothing when there are none.
Future<void> startSession(BuildContext context, List<DueItem> items) async {
  if (items.isEmpty) {
    return;
  }
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) =>
          SessionScreen(items: items.map(_toSessionItem).toList()),
    ),
  );
}

/// Replaces the current session by a new one, for "Revoir les ratées".
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
    SessionItem(cardId: item.card.card.id, directionId: item.direction.id);
