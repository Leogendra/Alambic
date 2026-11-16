import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/formatting/preset_labels.dart';
import '../../app/layout/scroll_padding.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/surface_panel.dart';
import '../../app/widgets/text_input_dialog.dart';
import '../../application/groups/group_providers.dart';
import '../../application/pauses/pause_providers.dart';
import '../../application/presets/preset_providers.dart';
import '../../domain/groups/card_group.dart';
import '../../domain/presets/preset_catalog.dart';
import '../../l10n/generated/app_localizations.dart';
import '../presets/preset_picker.dart';

/// Name, preset, back, pause and deletion of a group.
class GroupSettingsScreen extends ConsumerWidget {
  const GroupSettingsScreen({required this.groupId, super.key});

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final group = ref.watch(groupProvider(groupId)).value;
    final catalog = ref.watch(presetCatalogProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(strings.groupSettingsTitle)),
      body: group == null || catalog == null
          ? const SizedBox.shrink()
          : ListView(
              padding: scrollPadding(
                context,
                const EdgeInsets.fromLTRB(20, 8, 20, 32),
              ),
              children: [
                SurfacePanel(children: [_nameRow(context, ref, group)]),
                const SizedBox(height: 24),
                SectionLabel(strings.groupSettingsRepetition),
                SurfacePanel(
                  children: [
                    _presetRow(context, ref, group, catalog),
                    _reverseRow(context, ref, group),
                  ],
                ),
                _hint(context, strings.groupSettingsPresetHint),
                const SizedBox(height: 24),
                SurfacePanel(children: [_pauseRow(context, ref, group)]),
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

  Widget _presetRow(
    BuildContext context,
    WidgetRef ref,
    CardGroup group,
    PresetCatalog catalog,
  ) {
    final strings = AppLocalizations.of(context);
    final preset = catalog.presetForGroup(group.id);
    return PanelRow(
      title: strings.cardPreset,
      subtitle: strings.presetStepsSummary(preset),
      value: group.presetId == null
          ? strings.cardPresetInheritedGlobal(strings.presetName(preset))
          : strings.presetName(preset),
      onTap: () async {
        final choice = await showPresetPicker(
          context,
          presets: catalog.presetsById.values.toList(),
          selectedPresetId: group.presetId,
          inheritedPreset: catalog.globalPreset,
        );
        if (choice != null) {
          await ref
              .read(groupServiceProvider)
              .setPreset(group.id, choice.presetId);
        }
      },
    );
  }

  Widget _reverseRow(BuildContext context, WidgetRef ref, CardGroup group) {
    final strings = AppLocalizations.of(context);
    return PanelRow(
      title: strings.groupReverse,
      subtitle: group.reverseEnabled
          ? strings.groupReverseOnHint
          : strings.groupReverseOffHint,
      trailing: Switch(
        value: group.reverseEnabled,
        onChanged: (enabled) => ref
            .read(groupServiceProvider)
            .setReverseEnabled(group.id, enabled: enabled),
      ),
    );
  }

  Widget _pauseRow(BuildContext context, WidgetRef ref, CardGroup group) {
    final strings = AppLocalizations.of(context);
    final pausedAt = group.pausedAt;
    return PanelRow(
      title: strings.pauseGroup,
      subtitle: pausedAt == null
          ? strings.pauseGroupHint
          : strings.pausedSince(strings.shortDate(pausedAt)),
      trailing: Switch(
        value: pausedAt != null,
        onChanged: (paused) {
          final service = ref.read(pauseServiceProvider);
          paused ? service.pauseGroup(group.id) : service.resumeGroup(group.id);
        },
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

  Widget _hint(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: AlambicColors.of(context).textSecondary,
      ),
    ),
  );
}
