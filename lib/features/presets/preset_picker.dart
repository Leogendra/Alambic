import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/preset_labels.dart';
import '../../app/widgets/choice_tile.dart';
import '../../application/groups/group_providers.dart';
import '../../application/presets/preset_providers.dart';
import '../../domain/presets/preset.dart';
import '../../l10n/generated/app_localizations.dart';
import 'presets_screen.dart';

/// What the preset picker returns.
sealed class PresetPick {
  const PresetPick();
}

/// An existing preset, by id.
class ExistingPresetPick extends PresetPick {
  const ExistingPresetPick(this.presetId);

  final int presetId;
}

/// A preset to create.
class NewPresetPick extends PresetPick {
  const NewPresetPick();
}

/// Bottom sheet listing the presets, with "New preset" at the end; returns
/// what was tapped, or `null` when dismissed.
Future<PresetPick?> showPresetPicker(
  BuildContext context, {
  required List<Preset> presets,
  required int selectedPresetId,
}) => showModalBottomSheet<PresetPick>(
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
              strings.presetPickerTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final preset in presets)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ChoiceTile(
                label: strings.presetName(preset),
                detail: strings.presetStepsSummary(preset),
                isSelected: selectedPresetId == preset.id,
                onTap: () =>
                    Navigator.of(context).pop(ExistingPresetPick(preset.id)),
              ),
            ),
          const SizedBox(height: 4),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(const NewPresetPick()),
            icon: const Icon(Icons.add),
            label: Text(strings.presetsNew),
          ),
        ],
      ),
    );
  },
);

/// Lets the user pick the preset of a group: the group follows the one tapped,
/// or a new one once it is saved.
Future<void> chooseGroupPreset(
  BuildContext context,
  WidgetRef ref,
  int groupId,
) async {
  final catalog = await ref.read(presetCatalogProvider.future);
  if (!context.mounted) {
    return;
  }
  final pick = await showPresetPicker(
    context,
    presets: catalog.presetsById.values.toList(),
    selectedPresetId: catalog.presetForGroup(groupId).id,
  );
  if (!context.mounted) {
    return;
  }
  final presetId = switch (pick) {
    ExistingPresetPick(:final presetId) => presetId,
    NewPresetPick() => await openPresetEditor(
      context,
      ref
          .read(presetServiceProvider)
          .newDraft(AppLocalizations.of(context).presetNewName),
    ),
    null => null,
  };
  if (presetId != null) {
    await ref.read(groupServiceProvider).setPreset(groupId, presetId);
  }
}
