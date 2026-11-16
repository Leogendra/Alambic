import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/section_label.dart';
import '../../application/distillation/distillation_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'distill_screen.dart';
import 'distillation_tile.dart';

/// Distillation of a group page: the large "Distill" button while the group
/// does not distill, then the tracking of its distillation.
class GroupDistillationSection extends ConsumerWidget {
  const GroupDistillationSection({required this.groupId, super.key});

  final int groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final distillation = ref.watch(groupDistillationProvider(groupId));
    if (distillation == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => DistillScreen(groupId: groupId),
              ),
            ),
            child: Text(strings.distillTitle),
          ),
          Text(
            strings.groupDistillationNone,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AlambicColors.of(context).textSecondary,
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(strings.groupDistillationSection),
          DistillationTile(progress: distillation),
        ],
      );
    }
  }
}
