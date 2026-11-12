import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/section_label.dart';
import '../../application/distillation/distillation_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'distillation_launch_screen.dart';
import 'distillation_tile.dart';

/// "Distillation" section of a group page: its distillations in progress and
/// the "Distill" button.
class GroupDistillationsSection extends ConsumerWidget {
  const GroupDistillationsSection({required this.groupId, super.key});

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final distillations = ref.watch(groupDistillationsProvider(groupId));
    final globalInProgress = ref.watch(globalDistillationProvider) != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          children: [
            Expanded(child: SectionLabel(strings.groupDistillationSection)),
            FilledButton.tonalIcon(
              // The theme stretches filled buttons to the full width.
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              icon: const Icon(Icons.water_drop_outlined, size: 18),
              label: Text(strings.distillTitle),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) =>
                      DistillationLaunchScreen(groupId: groupId),
                ),
              ),
            ),
          ],
        ),
        if (distillations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              globalInProgress
                  ? strings.groupDistillationGlobal
                  : strings.groupDistillationNone,
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
          )
        else
          for (final progress in distillations)
            DistillationTile(progress: progress),
      ],
    );
  }
}
