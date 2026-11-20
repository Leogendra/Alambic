import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/count_badge.dart';
import '../../application/groups/group_summary.dart';
import '../../l10n/generated/app_localizations.dart';

/// A row of the groups tab: name, number of cards, "distillation" once it
/// is activated or "Paused" while it is paused, and the due badge, or a
/// pause icon when a paused group has nothing due.
class GroupSummaryTile extends StatelessWidget {
  const GroupSummaryTile({
    required this.summary,
    required this.onTap,
    super.key,
  });

  final GroupSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final cards = strings.cardCount(summary.cardCount);
    final group = summary.group;
    final paused = summary.isDistillationPaused;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      group.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: paused ? colors.textSecondary : null,
                      ),
                    ),
                    Text(
                      paused
                          ? strings.groupLinePaused(cards)
                          : summary.isDistilling
                          ? strings.groupLineDistilling(cards)
                          : cards,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (summary.dueCount > 0)
                CountBadge(summary.dueCount)
              else if (paused)
                Icon(Icons.pause, color: colors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
