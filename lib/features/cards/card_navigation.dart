import 'package:flutter/material.dart';

import 'card_editor_screen.dart';

/// Opens a card from a list.
Future<void> openCard(BuildContext context, int cardId) => Navigator.of(context)
    .push(
      MaterialPageRoute<void>(
        builder: (context) => CardEditorScreen(cardId: cardId),
      ),
    );

/// Opens the editor of a new card, in [groupId] when given.
Future<void> openNewCard(BuildContext context, {int? groupId}) =>
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => CardEditorScreen(initialGroupId: groupId),
      ),
    );
