import 'package:flutter/material.dart';

import '../../app/formatting/preset_labels.dart';
import '../../app/widgets/choice_tile.dart';
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
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Text(
              strings.presetPickerTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          if (inheritedPreset != null)
            _entry(
              context,
              title: strings.presetPickerInherit(
                strings.presetName(inheritedPreset),
              ),
              subtitle: strings.presetStepsSummary(inheritedPreset),
              isSelected: selectedPresetId == null,
              choice: const PresetChoice.inherit(),
            ),
          for (final preset in presets)
            _entry(
              context,
              title: strings.presetName(preset),
              subtitle: strings.presetStepsSummary(preset),
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
}) => Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: ChoiceTile(
    label: title,
    detail: subtitle,
    isSelected: isSelected,
    onTap: () => Navigator.of(context).pop(choice),
  ),
);
