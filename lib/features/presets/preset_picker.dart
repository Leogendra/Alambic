import 'package:material_ui/material_ui.dart';

import '../../app/formatting/preset_labels.dart';
import '../../app/widgets/choice_tile.dart';
import '../../domain/presets/preset.dart';
import '../../l10n/generated/app_localizations.dart';

/// Bottom sheet listing the presets; returns the id of the one tapped, or
/// `null` when dismissed.
Future<int?> showPresetPicker(
  BuildContext context, {
  required List<Preset> presets,
  required int selectedPresetId,
}) => showModalBottomSheet<int>(
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
                onTap: () => Navigator.of(context).pop(preset.id),
              ),
            ),
        ],
      ),
    );
  },
);
