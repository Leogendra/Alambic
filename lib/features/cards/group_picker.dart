import 'package:flutter/material.dart';

import '../../domain/groups/card_group.dart';
import '../../l10n/generated/app_localizations.dart';
import 'group_choice.dart';

/// Bottom sheet to put a card in a group, or in "Sans groupe".
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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              strings.groupPickerTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            title: Text(strings.noGroup),
            trailing: selectedGroupId == null ? const Icon(Icons.check) : null,
            onTap: () => Navigator.of(context).pop(const GroupChoice(null)),
          ),
          for (final group in groups)
            ListTile(
              title: Text(group.name),
              trailing: selectedGroupId == group.id
                  ? const Icon(Icons.check)
                  : null,
              onTap: () => Navigator.of(context).pop(GroupChoice(group.id)),
            ),
        ],
      ),
    );
  },
);
