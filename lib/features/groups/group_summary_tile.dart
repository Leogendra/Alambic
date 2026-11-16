import 'package:flutter/material.dart';

import '../../app/formatting/preset_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/count_badge.dart';
import '../../application/groups/group_summary.dart';
import '../../l10n/generated/app_localizations.dart';

/// A group in the groups tab: name, card count, preset and due badge, or
/// the pause of a paused group.
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
    final paused = group.isPaused;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    Text(
                      group.name,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: paused ? colors.textSecondary : null,
                      ),
                    ),
                    Text(
                      paused
                          ? strings.groupLinePaused(cards)
                          : strings.groupLine(
                              cards,
                              strings.presetName(summary.preset),
                            ),
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (paused)
                Icon(Icons.pause, color: colors.textSecondary)
              else if (summary.dueCount > 0)
                CountBadge(summary.dueCount),
            ],
          ),
        ),
      ),
    );
  }
}
