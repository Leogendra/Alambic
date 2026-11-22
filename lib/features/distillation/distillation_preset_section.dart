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
import '../../l10n/generated/app_localizations.dart';
import '../presets/preset_picker.dart';
import '../presets/presets_screen.dart';

/// The preset followed by the cards of the group, with its reminders: the
/// default preset until the group chooses one. It is edited here, swapped
/// for another or replaced by a new one, applied at once, without "Save".
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Text(
                          strings.presetName(preset),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (group.presetId == null)
                        BadgeLabel(strings.presetGlobalBadge),
                    ],
                  ),
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      CompactButton(
                        label: strings.presetEdit,
                        onPressed: () => openPresetEditor(context, preset),
                      ),
                      CompactButton(
                        label: strings.distillPresetChange,
                        onPressed: () => _choose(context, ref),
                      ),
                      CompactButton(
                        label: strings.presetsNew,
                        onPressed: () => _create(context, ref),
                      ),
                    ],
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

  Future<void> _choose(BuildContext context, WidgetRef ref) async {
    final catalog = await ref.read(presetCatalogProvider.future);
    final group = ref.read(groupSummaryProvider(groupId))?.group;
    if (!context.mounted || group == null) {
      return;
    }
    final choice = await showPresetPicker(
      context,
      presets: catalog.presetsById.values.toList(),
      selectedPresetId: group.presetId,
      inheritedPreset: catalog.globalPreset,
    );
    if (choice != null) {
      await ref.read(groupServiceProvider).setPreset(groupId, choice.presetId);
    }
  }

  /// A new preset, which the group follows once it is saved.
  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final strings = AppLocalizations.of(context);
    final draft = ref
        .read(presetServiceProvider)
        .newDraft(strings.presetNewName);
    final presetId = await openPresetEditor(context, draft);
    if (presetId != null) {
      await ref.read(groupServiceProvider).setPreset(groupId, presetId);
    }
  }
}
