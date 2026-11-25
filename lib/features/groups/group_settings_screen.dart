import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/layout/scroll_padding.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/surface_panel.dart';
import '../../app/widgets/text_input_dialog.dart';
import '../../application/groups/group_providers.dart';
import '../../domain/groups/card_group.dart';
import '../../l10n/generated/app_localizations.dart';

/// Name, typed answer, back and deletion of a group. The preset and what
/// comes after its last step are set from the "Distill" screen.
class GroupSettingsScreen extends ConsumerWidget {
  const GroupSettingsScreen({required this.groupId, super.key});

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final group = ref.watch(groupProvider(groupId)).value;
    return Scaffold(
      appBar: AppBar(title: Text(strings.groupSettingsTitle)),
      body: group == null
          ? const SizedBox.shrink()
          : ListView(
              padding: scrollPadding(
                context,
                const EdgeInsets.fromLTRB(20, 8, 20, 32),
              ),
              children: [
                SurfacePanel(children: [_nameRow(context, ref, group)]),
                const SizedBox(height: 24),
                SurfacePanel(
                  children: [
                    _typedAnswerRow(context, ref, group),
                    _reverseRow(context, ref, group),
                  ],
                ),
                const SizedBox(height: 24),
                SurfacePanel(children: [_deleteRow(context, ref, group)]),
              ],
            ),
    );
  }

  Widget _nameRow(BuildContext context, WidgetRef ref, CardGroup group) {
    final strings = AppLocalizations.of(context);
    return PanelRow(
      title: strings.groupNameLabel,
      value: group.name,
      onTap: () async {
        final name = await showTextInputDialog(
          context,
          title: strings.groupNameLabel,
          label: strings.groupNameLabel,
          initialText: group.name,
        );
        if (name != null) {
          await ref.read(groupServiceProvider).rename(group.id, name);
        }
      },
    );
  }

  Widget _typedAnswerRow(BuildContext context, WidgetRef ref, CardGroup group) {
    final strings = AppLocalizations.of(context);
    return PanelRow(
      title: strings.groupTypedAnswer,
      subtitle: strings.groupTypedAnswerHint,
      trailing: Switch(
        value: group.typedAnswer,
        onChanged: (enabled) => ref
            .read(groupServiceProvider)
            .setTypedAnswer(group.id, enabled: enabled),
      ),
    );
  }

  Widget _reverseRow(BuildContext context, WidgetRef ref, CardGroup group) {
    final strings = AppLocalizations.of(context);
    return PanelRow(
      title: strings.groupReverse,
      subtitle: strings.groupReverseHint,
      trailing: Switch(
        value: group.reverseEnabled,
        onChanged: (enabled) => ref
            .read(groupServiceProvider)
            .setReverseEnabled(group.id, enabled: enabled),
      ),
    );
  }

  Widget _deleteRow(BuildContext context, WidgetRef ref, CardGroup group) {
    final strings = AppLocalizations.of(context);
    final summary = ref.watch(groupSummaryProvider(group.id));
    return PanelRow(
      title: strings.groupDelete,
      titleColor: Theme.of(context).colorScheme.error,
      trailing: Icon(
        Icons.delete_outline,
        color: Theme.of(context).colorScheme.error,
      ),
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.groupDeleteConfirmTitle(group.name)),
            content: Text(
              strings.groupDeleteConfirmBody(summary?.cardCount ?? 0),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(strings.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(strings.commonDelete),
              ),
            ],
          ),
        );
        if (confirmed == true && context.mounted) {
          await ref.read(groupServiceProvider).delete(group.id);
          if (context.mounted) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      },
    );
  }
}
