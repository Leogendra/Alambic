import 'package:flutter/material.dart';

import '../../app/theme/remanence_colors.dart';
import '../../app/widgets/count_badge.dart';
import '../../application/groups/group_summary.dart';
import '../../l10n/generated/app_localizations.dart';

/// A group in the groups tab: name, card count, preset and due badge.
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
    final colors = RemanenceColors.of(context);
    final cards = strings.cardCount(summary.cardCount);
    final group = summary.group;
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
                      group?.name ?? strings.noGroup,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      group == null
                          ? strings.noGroupLine(cards)
                          : strings.groupLine(cards, summary.preset.name),
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (summary.dueCount > 0) CountBadge(summary.dueCount),
            ],
          ),
        ),
      ),
    );
  }
}
