import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/widgets/panel_row.dart';
import '../../app/widgets/text_input_dialog.dart';
import '../../application/groups/group_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'group_picker.dart';

/// The group row of a [SurfacePanel] where cards are created: the chosen
/// group, which the row changes, and a "+" button that creates a group from
/// its name and chooses it. Every card needs a group, so with no group yet
/// the row itself asks for a name.
class GroupField extends ConsumerWidget {
  const GroupField({required this.groupId, required this.onChanged, super.key});

  final int? groupId;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final groups = ref.watch(groupsProvider).value ?? const [];
    final groupName = groups
        .where((group) => group.id == groupId)
        .map((group) => group.name)
        .firstOrNull;
    return PanelRow(
      title: strings.cardGroup,
      value: groupName ?? strings.cardGroupNone,
      showsChevron: true,
      trailing: IconButton.outlined(
        tooltip: strings.newGroupTitle,
        icon: const Icon(Icons.add),
        onPressed: () => _createGroup(context, ref),
      ),
      onTap: () async {
        if (groups.isEmpty) {
          await _createGroup(context, ref);
        } else {
          final choice = await showGroupPicker(
            context,
            groups: groups,
            selectedGroupId: groupId,
          );
          if (choice != null) {
            onChanged(choice.groupId);
          }
        }
      },
    );
  }

  Future<void> _createGroup(BuildContext context, WidgetRef ref) async {
    final strings = AppLocalizations.of(context);
    final name = await showTextInputDialog(
      context,
      title: strings.newGroupTitle,
      label: strings.groupNameLabel,
    );
    if (name != null) {
      onChanged(await ref.read(groupServiceProvider).create(name));
    }
  }
}
