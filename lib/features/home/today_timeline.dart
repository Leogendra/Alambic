import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/remanence_colors.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/groups/group_providers.dart';
import '../../application/home/timeline_entry.dart';
import '../../application/home/today_overview.dart';
import '../../domain/presets/grouped_reminder_action.dart';
import '../../domain/presets/notification_mode.dart';
import '../../domain/scheduling/clock_time.dart';
import '../../l10n/generated/app_localizations.dart';

/// Today's reminders, in time order: past ones greyed, the next one
/// highlighted, later ones as hollow dots.
class TodayTimeline extends ConsumerWidget {
  const TodayTimeline({required this.overview, required this.now, super.key});

  final TodayOverview overview;
  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = RemanenceColors.of(context);
    if (overview.timeline.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Text(
          strings.homeTimelineEmpty,
          style: TextStyle(fontSize: 14, color: colors.textSecondary),
        ),
      );
    }
    final groups = ref.watch(groupsProvider).value ?? const [];
    final nextIndex = overview.nextIndex(now);
    return SurfacePanel(
      children: [
        for (var index = 0; index < overview.timeline.length; index++)
          _row(
            strings,
            colors,
            overview.timeline[index],
            groupName: (int? groupId) =>
                groups
                    .where((group) => group.id == groupId)
                    .map((group) => group.name)
                    .firstOrNull ??
                strings.noGroup,
            isPast: nextIndex == null || index < nextIndex,
            isNext: index == nextIndex,
          ),
      ],
    );
  }

  Widget _row(
    AppLocalizations strings,
    RemanenceColors colors,
    TimelineEntry entry, {
    required String Function(int? groupId) groupName,
    required bool isPast,
    required bool isNext,
  }) {
    final textColor = isPast ? colors.textSecondary : colors.textPrimary;
    return SizedBox(
      height: 52,
      child: Row(
        spacing: 12,
        children: [
          SizedBox(
            width: 44,
            child: Text(
              ClockTime(entry.at.hour, entry.at.minute).toString(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: isNext ? FontWeight.w700 : FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
          _dot(colors, isPast: isPast, isNext: isNext),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.isExtraReminder
                      ? strings.cardSheetReviewSoon
                      : groupName(entry.groupId),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isNext ? FontWeight.w600 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
                Text(
                  isPast
                      ? strings.homeTimelineRemaining(entry.count)
                      : _detail(strings, entry),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: colors.textSecondary),
                ),
              ],
            ),
          ),
          if (isNext)
            Text(
              strings.homeTimelineNext,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colors.accentText,
              ),
            ),
        ],
      ),
    );
  }

  String _detail(AppLocalizations strings, TimelineEntry entry) {
    final preset = entry.preset;
    if (preset == null) {
      return strings.homeTimelineExtra(entry.count);
    }
    return switch (preset.notificationMode) {
      NotificationMode.perCard => strings.homeTimelinePerCard(entry.count),
      NotificationMode.grouped => switch (preset.groupedAction) {
        GroupedReminderAction.openApp => strings.homeTimelineGrouped(
          entry.count,
        ),
        GroupedReminderAction.chainInNotification =>
          strings.homeTimelineChained(entry.count),
      },
    };
  }

  Widget _dot(
    RemanenceColors colors, {
    required bool isPast,
    required bool isNext,
  }) => Container(
    width: 10,
    height: 10,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: isPast
          ? colors.textSecondary.withValues(alpha: 0.4)
          : isNext
          ? colors.accent
          : null,
      border: isPast || isNext
          ? null
          : Border.all(color: colors.accent, width: 2),
      boxShadow: isNext
          ? [BoxShadow(color: colors.accentTint, spreadRadius: 4)]
          : null,
    ),
  );
}
