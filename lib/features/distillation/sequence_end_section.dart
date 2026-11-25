import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/interval_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/segment_option.dart';
import '../../app/widgets/segmented_choice.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/groups/group_providers.dart';
import '../../application/presets/preset_providers.dart';
import '../../domain/groups/after_last_step.dart';
import '../../domain/groups/remanence_interval.dart';
import '../../l10n/generated/app_localizations.dart';

/// What comes after the last step of the preset: remanence or acquired, the
/// interval of the remanence, and what the choice does to a card past the
/// last step. Every change applies at once, without "Save".
class SequenceEndSection extends ConsumerWidget {
  const SequenceEndSection({required this.groupId, super.key});

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final group = ref.watch(groupProvider(groupId)).value;
    final catalog = ref.watch(presetCatalogProvider).value;
    if (group == null || catalog == null) {
      return const SizedBox.shrink();
    }
    final service = ref.read(groupServiceProvider);
    final remanence = group.afterLastStep == AfterLastStep.remanence;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(strings.groupAfterLastStep),
        SurfacePanel(
          padding: const EdgeInsets.all(16),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 12,
              children: [
                SegmentedChoice<AfterLastStep>(
                  options: [
                    SegmentOption(
                      AfterLastStep.acquired,
                      strings.groupAcquired,
                    ),
                    SegmentOption(
                      AfterLastStep.remanence,
                      strings.groupRemanence,
                    ),
                  ],
                  selected: group.afterLastStep,
                  onSelected: (value) =>
                      service.setAfterLastStep(group.id, value),
                ),
                if (remanence) ...[
                  Text(
                    strings.groupRemanenceEvery,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SegmentedChoice<RemanenceInterval>(
                    options: [
                      for (final interval in RemanenceInterval.values)
                        SegmentOption(
                          interval,
                          strings.intervalLabel(interval.interval),
                        ),
                    ],
                    selected: group.remanenceInterval,
                    onSelected: (value) =>
                        service.setRemanenceInterval(group.id, value),
                  ),
                ],
                Text(
                  remanence
                      ? strings.groupRemanenceEffect(
                          strings.intervalLabel(
                            group.sequenceEnd.remanenceAfter(
                              catalog.presetForGroup(group.id),
                            ),
                          ),
                        )
                      : strings.groupAcquiredEffect,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: AlambicColors.of(context).textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
