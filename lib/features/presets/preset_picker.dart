import 'package:flutter/material.dart';

import '../../app/formatting/preset_labels.dart';
import '../../domain/presets/preset.dart';
import '../../l10n/generated/app_localizations.dart';
import 'preset_choice.dart';

/// Bottom sheet listing the presets. With [inheritedPreset], a first entry
/// lets the level inherit it instead of choosing one.
Future<PresetChoice?> showPresetPicker(
  BuildContext context, {
  required List<Preset> presets,
  required int? selectedPresetId,
  Preset? inheritedPreset,
}) => showModalBottomSheet<PresetChoice>(
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
              strings.presetPickerTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (inheritedPreset != null)
            _entry(
              context,
              title: strings.presetPickerInherit(inheritedPreset.name),
              subtitle: strings.presetSummary(inheritedPreset),
              isSelected: selectedPresetId == null,
              choice: const PresetChoice.inherit(),
            ),
          for (final preset in presets)
            _entry(
              context,
              title: preset.name,
              subtitle: strings.presetSummary(preset),
              isSelected: selectedPresetId == preset.id,
              choice: PresetChoice.preset(preset.id),
            ),
        ],
      ),
    );
  },
);

Widget _entry(
  BuildContext context, {
  required String title,
  required String subtitle,
  required bool isSelected,
  required PresetChoice choice,
}) => ListTile(
  title: Text(title),
  subtitle: Text(subtitle),
  trailing: isSelected ? const Icon(Icons.check) : null,
  onTap: () => Navigator.of(context).pop(choice),
);
