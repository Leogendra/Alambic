import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/groups/group_providers.dart';
import '../../application/home/home_timeline.dart';
import '../../application/home/timeline_arrival.dart';
import '../../application/home/timeline_card.dart';
import '../../application/home/timeline_day.dart';
import '../../domain/groups/card_group.dart';
import '../../domain/scheduling/clock_time.dart';
import '../../l10n/generated/app_localizations.dart';
import '../cards/card_navigation.dart';
import '../cards/card_status_formatter.dart';
import '../cards/card_status_formatter_provider.dart';
import '../groups/group_detail_screen.dart';

/// Home's timeline: today outlined, with its late cards first, then the next
/// days. Each day lists its reminders card by card with their label and the
/// time left, then a line per group receiving new cards. The coming month
/// and year close it, as two totals.
class HomeTimelineView extends ConsumerWidget {
  const HomeTimelineView({required this.timeline, super.key});

  final HomeTimeline timeline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = watchCardStatusFormatter(context, ref);
    if (formatter == null) {
      return const SizedBox.shrink();
    }
    final groupNames = <int, String>{
      for (final group
          in ref.watch(groupsProvider).value ?? const <CardGroup>[])
        group.id: group.name,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 20,
      children: [
        for (final day in timeline.days)
          _DaySection(
            day: day,
            isTomorrow: _isTomorrow(day),
            formatter: formatter,
            groupNames: groupNames,
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Expanded(
              child: _ComingBlock(
                title: formatter.strings.homeComingMonth,
                total: timeline.comingMonth,
              ),
            ),
            Expanded(
              child: _ComingBlock(
                title: formatter.strings.homeComingYear,
                total: timeline.comingYear,
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _isTomorrow(TimelineDay day) {
    final today = timeline.today.day;
    return day.day == DateTime(today.year, today.month, today.day + 1);
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.day,
    required this.isTomorrow,
    required this.formatter,
    required this.groupNames,
  });

  final TimelineDay day;
  final bool isTomorrow;
  final CardStatusFormatter formatter;
  final Map<int, String> groupNames;

  @override
  Widget build(BuildContext context) {
    final strings = formatter.strings;
    final colors = AlambicColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(
          day.isToday
              ? strings.homeToday
              : isTomorrow
              ? strings.homeTomorrow
              : strings.dayDate(day.day),
        ),
        SurfacePanel(
          borderColor: day.isToday ? colors.accent : null,
          children: [
            for (final card in day.cards)
              _CardRow(
                entry: card,
                isToday: day.isToday,
                formatter: formatter,
                groupName: groupNames[card.card.groupId] ?? '',
              ),
            for (final arrival in day.arrivals)
              _ArrivalRow(
                arrival: arrival,
                groupName: groupNames[arrival.groupId] ?? '',
              ),
            if (day.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  strings.homeTodayEmpty,
                  style: TextStyle(fontSize: 14, color: colors.textSecondary),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// A card reminder: its front, its group with "late" or the time of today's
/// reminder, "Review soon" for an extra reminder, and the time left.
class _CardRow extends StatelessWidget {
  const _CardRow({
    required this.entry,
    required this.isToday,
    required this.formatter,
    required this.groupName,
  });

  final TimelineCard entry;
  final bool isToday;
  final CardStatusFormatter formatter;
  final String groupName;

  @override
  Widget build(BuildContext context) {
    final strings = formatter.strings;
    final colors = AlambicColors.of(context);
    return InkWell(
      onTap: () => openCard(context, entry.card.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    entry.card.frontText ?? strings.cardImageOnly,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: groupName),
                        if (entry.isLate)
                          TextSpan(
                            text: ' · ${strings.homeLate}',
                            style: TextStyle(color: colors.againForeground),
                          )
                        else if (isToday)
                          TextSpan(text: ' · ${_time(strings)}'),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (entry.isExtraReminder)
              Text(
                strings.cardSheetReviewSoon,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.accentText,
                ),
              ),
            if (entry.delay case final delay?)
              Text(
                delay.inDays
                    ? strings.homeDelayDays(delay.count)
                    : strings.homeDelayHours(delay.count),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.accentText,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// "at 12:00".
  String _time(AppLocalizations strings) =>
      strings.dueAtTime(ClockTime(entry.at.hour, entry.at.minute).toString());
}

/// "Capitals: 2 new cards", opening the group.
class _ArrivalRow extends StatelessWidget {
  const _ArrivalRow({required this.arrival, required this.groupName});

  final TimelineArrival arrival;
  final String groupName;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => GroupDetailScreen(groupId: arrival.groupId),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          spacing: 10,
          children: [
            Icon(Icons.water_drop_outlined, size: 18, color: colors.accent),
            Expanded(
              child: Text(
                strings.homeArrivals(groupName, arrival.count),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Coming month": the cards expected, as a total and a pile whose height
/// follows it. Not touchable.
class _ComingBlock extends StatelessWidget {
  const _ComingBlock({required this.title, required this.total});

  /// Most slices of a pile: what its height holds.
  static const int _maxSlices = 7;

  /// Small shifts of the slices, so that they look stacked by hand.
  static const List<double> _shifts = [0, 3, 1, 4, 2, 0, 3];

  final String title;
  final int total;

  /// One slice, then one more each time the total doubles.
  int get _slices => total.bitLength.clamp(0, _maxSlices);

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
              color: colors.textSecondary,
            ),
          ),
          Text(
            strings.cardCount(total),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          ExcludeSemantics(
            child: SizedBox(
              height: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 3,
                children: [
                  for (var slice = _slices - 1; slice >= 0; slice--)
                    Container(
                      width: 84,
                      height: 6,
                      margin: EdgeInsetsDirectional.only(start: _shifts[slice]),
                      decoration: BoxDecoration(
                        color: colors.accentTint,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: colors.accent.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
