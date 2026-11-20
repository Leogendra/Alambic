import 'package:material_ui/material_ui.dart';

import 'card_editor_screen.dart';
import 'card_sheet_screen.dart';

/// Opens the sheet of a card from a list.
Future<void> openCard(BuildContext context, int cardId) => Navigator.of(context)
    .push(
      MaterialPageRoute<void>(
        builder: (context) => CardSheetScreen(cardId: cardId),
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
