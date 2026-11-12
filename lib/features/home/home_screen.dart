import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/formatting/review_duration_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/section_label.dart';
import '../../application/groups/group_providers.dart';
import '../../application/groups/group_summary.dart';
import '../../application/home/home_providers.dart';
import '../../application/home/today_overview.dart';
import '../../application/reviews/review_providers.dart';
import '../../application/time/minute_ticker.dart';
import '../../l10n/generated/app_localizations.dart';
import '../groups/group_detail_screen.dart';
import '../session/session_launcher.dart';
import 'today_timeline.dart';

/// Home tab: what is due now, today's reminders, and the groups to review or
/// to start.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final overview = ref.watch(todayOverviewProvider);
    final now = ref.watch(currentMomentProvider).value;
    if (overview == null || now == null) {
      return const SizedBox.shrink();
    }
    final summaries = ref.watch(groupSummariesProvider);
    final dueGroups = summaries.where((summary) => summary.dueCount > 0);
    final newGroups = summaries.where((summary) => summary.unstartedCount > 0);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 96),
      children: [
        _header(context, now),
        const SizedBox(height: 20),
        _DuePanel(overview: overview),
        const SizedBox(height: 20),
        SectionLabel(strings.homeTimeline),
        TodayTimeline(overview: overview, now: now),
        if (dueGroups.isNotEmpty) ...[
          const SizedBox(height: 20),
          SectionLabel(strings.homeDueGroups),
          _GroupGrid(
            summaries: dueGroups.toList(),
            count: (summary) => summary.dueCount,
          ),
        ],
        if (newGroups.isNotEmpty) ...[
          const SizedBox(height: 20),
          SectionLabel(strings.homeNewCards),
          _GroupGrid(
            summaries: newGroups.toList(),
            count: (summary) => summary.unstartedCount,
          ),
        ],
      ],
    );
  }

  Widget _header(BuildContext context, DateTime now) {
    final strings = AppLocalizations.of(context);
    final date = DateFormat.MMMMEEEEd(strings.localeName).format(now);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 2,
      children: [
        Text(
          strings.homeTitle,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        Text(
          date[0].toUpperCase() + date.substring(1),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AlambicColors.of(context).textSecondary,
          ),
        ),
      ],
    );
  }
}

/// "12 à réviser", the progress of the day and "Review all now".
class _DuePanel extends ConsumerWidget {
  const _DuePanel({required this.overview});

  final TodayOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final due = overview.dueCount;
    final total = due + overview.doneCount;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$due',
                style: const TextStyle(
                  fontSize: 40,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  strings.homeDueLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
              ),
              if (due > 0)
                Text(
                  strings.reviewDuration(due),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.textSecondary,
                  ),
                ),
            ],
          ),
          if (total > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: overview.doneCount / total,
                    minHeight: 6,
                    color: colors.accent,
                    backgroundColor: colors.segmentBackground,
                  ),
                ),
                Text(
                  strings.homeDoneOf(overview.doneCount, total),
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                ),
              ],
            ),
          if (due > 0)
            FilledButton.icon(
              onPressed: () =>
                  startSession(context, ref.read(dueItemsProvider)),
              icon: const Icon(Icons.chevron_right),
              iconAlignment: IconAlignment.end,
              label: Text(strings.homeReviewAll),
            )
          else
            Text(
              strings.homeNothingDue,
              style: TextStyle(fontSize: 14, color: colors.textSecondary),
            ),
        ],
      ),
    );
  }
}

/// Two-column grid of groups, each with a count badge, opening the group.
class _GroupGrid extends StatelessWidget {
  const _GroupGrid({required this.summaries, required this.count});

  final List<GroupSummary> summaries;
  final int Function(GroupSummary summary) count;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.9,
      children: [
        for (final summary in summaries)
          Material(
            color: colors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) =>
                      GroupDetailScreen(groupId: summary.groupId),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        summary.group?.name ?? strings.noGroup,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 28),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: colors.accentTint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${count(summary)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colors.accentText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
