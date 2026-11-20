import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/section_label.dart';
import '../../application/distillation/distillation_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'distill_screen.dart';
import 'distillation_tile.dart';

/// Distillation of a group page: the large "Distill" button while the group
/// does not distill, then the tracking of its distillation.
class GroupDistillationSection extends ConsumerWidget {
  const GroupDistillationSection({
    required this.groupId,
    this.highlighted = false,
    super.key,
  });

  final int groupId;

  /// Introduces the button with a line telling the cards wait for it.
  final bool highlighted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final distillation = ref.watch(groupDistillationProvider(groupId));
    if (distillation == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          if (highlighted)
            Text(
              strings.groupDistillWaiting,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.accentText,
              ),
            ),
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
            style: TextStyle(fontSize: 13, color: colors.textSecondary),
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
