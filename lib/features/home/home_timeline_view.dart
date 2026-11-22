import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/dashed_divider.dart';
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

/// Home's timeline, as an agenda: each day has its date on the left, with a
/// trait running down towards the next one, and its reminders card by card
/// with their group and the time left, then its new cards, grouped in a
/// single line. The coming month and year close it, as two totals.
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
      children: [
        for (final (index, day) in timeline.days.indexed)
          _DaySection(
            day: day,
            isTomorrow: _isTomorrow(day),
            isLast: index == timeline.days.length - 1,
            formatter: formatter,
            groupNames: groupNames,
          ),
        _FurtherAhead(month: timeline.comingMonth, year: timeline.comingYear),
      ],
    );
  }

  bool _isTomorrow(TimelineDay day) {
    final today = timeline.today.day;
    return day.day == DateTime(today.year, today.month, today.day + 1);
  }
}

/// One day: its date and trait, then what it holds.
class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.day,
    required this.isTomorrow,
    required this.isLast,
    required this.formatter,
    required this.groupNames,
  });

  static const double _gutterWidth = 52;
  static const double _padding = 16;

  /// Room kept under the date badge for its trait: gap, shortest trait and
  /// margin before the next day.
  static const double _traitRoom = 8 + 12 + 10;

  final TimelineDay day;
  final bool isTomorrow;

  /// The trait of the last day fades out, towards what lies further ahead.
  final bool isLast;
  final CardStatusFormatter formatter;
  final Map<int, String> groupNames;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    final badgeHeight = _DateBadge.heightOf(isToday: day.isToday);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: colors.divider)),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: _padding + badgeHeight + _traitRoom,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 16,
            children: [
              SizedBox(
                width: _gutterWidth,
                child: Padding(
                  padding: const EdgeInsets.only(top: _padding, bottom: 10),
                  child: Column(
                    children: [
                      _DateBadge(date: day.day, isToday: day.isToday),
                      const SizedBox(height: 8),
                      Expanded(child: _Trait(fadesOut: isLast)),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: _padding),
                  child: _content(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final strings = formatter.strings;
    final colors = AlambicColors.of(context);
    final label = day.isToday
        ? strings.homeToday
        : isTomorrow
        ? strings.homeTomorrow
        : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: day.isToday ? colors.accentText : colors.textSecondary,
              ),
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            for (final card in day.cards)
              _CardRow(
                entry: card,
                isToday: day.isToday,
                formatter: formatter,
                groupName: groupNames[card.card.groupId] ?? '',
              ),
            if (day.arrivals.isNotEmpty)
              _ArrivalsRow(
                arrivals: day.arrivals,
                groupNames: groupNames,
                alignWithBadge: label == null && day.cards.isEmpty,
              ),
            if (day.isEmpty)
              Text(
                strings.homeTodayEmpty,
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
              ),
          ],
        ),
      ],
    );
  }
}

/// The weekday and the number of a day; today's is filled in accent.
class _DateBadge extends StatelessWidget {
  const _DateBadge({required this.date, required this.isToday});

  static double heightOf({required bool isToday}) => isToday ? 60 : 46;

  final DateTime date;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    return Container(
      width: 52,
      height: heightOf(isToday: isToday),
      decoration: isToday
          ? BoxDecoration(
              color: colors.accent,
              borderRadius: BorderRadius.circular(14),
            )
          : null,
      // The badge keeps its size whatever the text size: its content shrinks.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              strings.weekdayShort(date).toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
                height: 1.2,
                color: isToday ? colors.onAccent : colors.textSecondary,
              ),
            ),
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                height: 1.1,
                color: isToday ? colors.onAccent : colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The trait under a date, running down towards the next day.
class _Trait extends StatelessWidget {
  const _Trait({required this.fadesOut});

  final bool fadesOut;

  @override
  Widget build(BuildContext context) {
    final trait = Container(
      width: 2,
      decoration: BoxDecoration(
        color: AlambicColors.of(context).border,
        borderRadius: BorderRadius.circular(1),
      ),
    );
    return ExcludeSemantics(
      child: fadesOut
          ? ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF000000), Color(0x00000000)],
              ).createShader(bounds),
              child: trait,
            )
          : trait,
    );
  }
}

/// A card reminder: its front, its group with "late", the time of today's
/// reminder or "Review soon", and the time left.
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
    final accent = TextStyle(
      color: colors.accentText,
      fontWeight: FontWeight.w600,
    );
    return InkWell(
      onTap: () => openCard(context, entry.card.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
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
                            style: TextStyle(
                              color: colors.againForeground,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        else if (isToday)
                          TextSpan(text: ' · ${_time()}', style: accent),
                        if (entry.isExtraReminder)
                          TextSpan(
                            text: ' · ${strings.cardSheetReviewSoon}',
                            style: accent,
                          ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (entry.delay case final delay?)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.accentTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  delay.inDays
                      ? strings.homeDelayDays(delay.count)
                      : strings.homeDelayHours(delay.count),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colors.accentText,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// "12:00".
  String _time() => ClockTime(entry.at.hour, entry.at.minute).toString();
}

/// "Capitals 2  Spanish 1": the groups receiving new cards that day, each one
/// opening its group.
class _ArrivalsRow extends StatelessWidget {
  const _ArrivalsRow({
    required this.arrivals,
    required this.groupNames,
    required this.alignWithBadge,
  });

  final List<TimelineArrival> arrivals;
  final Map<int, String> groupNames;

  /// The row opens its day: it is moved down to the middle of the date.
  final bool alignWithBadge;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    return Padding(
      padding: EdgeInsets.only(top: alignWithBadge ? 4 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Icon(
              Icons.water_drop_outlined,
              size: 16,
              color: colors.accentText,
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 14,
              children: [
                for (final arrival in arrivals)
                  Semantics(
                    label: strings.homeArrivals(
                      groupNames[arrival.groupId] ?? '',
                      arrival.count,
                    ),
                    excludeSemantics: true,
                    button: true,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              GroupDetailScreen(groupId: arrival.groupId),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: groupNames[arrival.groupId] ?? ''),
                              TextSpan(
                                text: ' ${arrival.count}',
                                style: TextStyle(
                                  color: colors.accentText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// What lies beyond the days: the cards of the coming month and year, as two
/// totals under a dashed rule.
class _FurtherAhead extends StatelessWidget {
  const _FurtherAhead({required this.month, required this.year});

  final int month;
  final int year;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 20,
        children: [
          Row(
            spacing: 12,
            children: [
              const Expanded(child: DashedDivider()),
              Text(
                strings.homeFurtherAhead.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: colors.textSecondary,
                ),
              ),
              const Expanded(child: DashedDivider()),
            ],
          ),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(end: 16),
                    child: _Total(
                      total: month,
                      caption: strings.homeCardsNextMonth(month),
                      color: colors.textPrimary,
                    ),
                  ),
                ),
                VerticalDivider(width: 1, color: colors.divider),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 20),
                    child: _Total(
                      total: year,
                      caption: strings.homeCardsNextYear(year),
                      color: colors.accentText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A total in large figures, with what it counts under it.
class _Total extends StatelessWidget {
  const _Total({
    required this.total,
    required this.caption,
    required this.color,
  });

  final int total;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          Text(
            NumberFormat.decimalPattern(strings.localeName).format(total),
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
              height: 1,
              color: color,
            ),
          ),
          Text(
            caption,
            style: TextStyle(
              fontSize: 13,
              color: AlambicColors.of(context).textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
