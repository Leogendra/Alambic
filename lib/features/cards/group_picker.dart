import 'package:material_ui/material_ui.dart';

import '../../app/widgets/choice_tile.dart';
import '../../domain/groups/card_group.dart';
import '../../l10n/generated/app_localizations.dart';
import 'group_choice.dart';

/// Bottom sheet to put a card in a group.
Future<GroupChoice?> showGroupPicker(
  BuildContext context, {
  required List<CardGroup> groups,
  required int? selectedGroupId,
}) => showModalBottomSheet<GroupChoice>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (context) {
    final strings = AppLocalizations.of(context);
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Text(
              strings.groupPickerTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final group in groups)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ChoiceTile(
                label: group.name,
                isSelected: selectedGroupId == group.id,
                onTap: () => Navigator.of(context).pop(GroupChoice(group.id)),
              ),
            ),
        ],
      ),
    );
  },
);
