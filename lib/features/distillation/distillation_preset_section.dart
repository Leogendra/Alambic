import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/interval_labels.dart';
import '../../app/formatting/preset_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/badge_label.dart';
import '../../app/widgets/compact_button.dart';
import '../../app/widgets/interval_chip.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/groups/group_providers.dart';
import '../../application/presets/preset_providers.dart';
import '../../domain/presets/preset.dart';
import '../../domain/presets/preset_catalog.dart';
import '../../l10n/generated/app_localizations.dart';
import '../presets/preset_picker.dart';
import '../presets/presets_screen.dart';

/// The preset followed by the cards of the group, with its reminders. Its name
/// opens the choice of another preset or of a new one, "Edit" its editor;
/// either applies at once, without "Save".
class DistillationPresetSection extends ConsumerWidget {
  const DistillationPresetSection({required this.groupId, super.key});

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final catalog = ref.watch(presetCatalogProvider).value;
    final group = ref.watch(groupSummaryProvider(groupId))?.group;
    if (catalog == null || group == null) {
      return const SizedBox.shrink();
    }
    final preset = catalog.presetForGroup(groupId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(strings.cardPreset),
        SurfacePanel(
          children: [
            _nameRow(context, ref, strings, colors, preset, catalog),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final interval in preset.intervals)
                        IntervalChip(label: strings.intervalLabel(interval)),
                    ],
                  ),
                  Text(
                    strings.presetFailureSummary(
                      strings.failureSummary(preset.failureBehavior),
                    ),
                    style: TextStyle(fontSize: 14, color: colors.textSecondary),
                  ),
                  CompactButton(
                    label: strings.presetEdit,
                    onPressed: () => openPresetEditor(context, preset),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
          child: Text(
            strings.distillPresetHint,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// The name of the preset, which opens the choice of another one.
  Widget _nameRow(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations strings,
    AlambicColors colors,
    Preset preset,
    PresetCatalog catalog,
  ) => InkWell(
    onTap: () => chooseGroupPreset(context, ref, groupId),
    child: ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: Text(
              strings.presetName(preset),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          if (preset.id == catalog.globalPresetId)
            BadgeLabel(strings.presetGlobalBadge),
          Icon(Icons.chevron_right, color: colors.textSecondary),
        ],
      ),
    ),
  );
}
