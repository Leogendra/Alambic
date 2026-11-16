import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/section_label.dart';
import '../../application/distillation/distillation_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'distill_screen.dart';
import 'distillation_tile.dart';

/// "Distillation" section of a group page: its distillation and the
/// "Distill" button.
class GroupDistillationsSection extends ConsumerWidget {
  const GroupDistillationsSection({required this.groupId, super.key});

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final distillation = ref.watch(groupDistillationProvider(groupId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          children: [
            Expanded(child: SectionLabel(strings.groupDistillationSection)),
            if (distillation == null)
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
                    builder: (context) => DistillScreen(groupId: groupId),
                  ),
                ),
              ),
          ],
        ),
        if (distillation == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(
              strings.groupDistillationNone,
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
          )
        else
          DistillationTile(progress: distillation),
      ],
    );
  }
}
