import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/formatting/interval_labels.dart';
import '../../app/formatting/preset_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/surface_panel.dart';
import '../../app/widgets/text_input_dialog.dart';
import '../../application/groups/group_providers.dart';
import '../../application/presets/preset_providers.dart';
import '../../domain/groups/card_group.dart';
import '../../domain/presets/preset_catalog.dart';
import '../../l10n/generated/app_localizations.dart';
import '../presets/preset_picker.dart';

/// Name, preset and deletion of a group.
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                SurfacePanel(children: [_nameRow(context, ref, group)]),
                const SizedBox(height: 24),
                SectionLabel(strings.groupSettingsRepetition),
                SurfacePanel(
                  children: [_presetRow(context, ref, group, catalog)],
                ),
                _hint(context, strings.groupSettingsPresetHint),
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
      trailing: Text(group.name, style: _valueStyle(context)),
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
    final sequence = preset.intervals.map(strings.intervalLabel).join(' · ');
    return PanelRow(
      title: strings.cardPreset,
      subtitle: '$sequence\n${strings.presetSummary(preset)}',
      trailing: Text(
        group.presetId == null
            ? strings.cardPresetInheritedGlobal(preset.name)
            : preset.name,
        style: _valueStyle(context),
      ),
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

  Widget _deleteRow(BuildContext context, WidgetRef ref, CardGroup group) {
    final strings = AppLocalizations.of(context);
    final summary = ref.watch(groupSummaryProvider(group.id));
    return PanelRow(
      title: strings.groupDelete,
      titleColor: Theme.of(context).colorScheme.error,
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

  TextStyle _valueStyle(BuildContext context) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AlambicColors.of(context).accentText,
  );
}
