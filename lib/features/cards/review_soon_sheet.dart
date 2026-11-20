import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/formatting/clock_time_conversions.dart';
import '../../app/formatting/date_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/choice_tile.dart';
import '../../application/clock.dart';
import '../../application/reminders/reminder_providers.dart';
import '../../domain/reviews/review_soon_days.dart';
import '../../domain/scheduling/clock_time.dart';
import '../../l10n/generated/app_localizations.dart';

/// Bottom sheet adding a one-off reminder to a card. Returns the moment
/// of the reminder, or `null` when dismissed.
Future<DateTime?> showReviewSoonSheet(
  BuildContext context, {
  required int cardId,
  required String front,
  required ClockTime defaultTime,
}) => showModalBottomSheet<DateTime>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (context) =>
      _ReviewSoonSheet(cardId: cardId, front: front, defaultTime: defaultTime),
);

class _ReviewSoonSheet extends ConsumerStatefulWidget {
  const _ReviewSoonSheet({
    required this.cardId,
    required this.front,
    required this.defaultTime,
  });

  final int cardId;
  final String front;
  final ClockTime defaultTime;

  @override
  ConsumerState<_ReviewSoonSheet> createState() => _ReviewSoonSheetState();
}

class _ReviewSoonSheetState extends ConsumerState<_ReviewSoonSheet> {
  late final ReviewSoonDays _days = ReviewSoonDays(
    calendar: ref.read(schedulingCalendarProvider),
    now: ref.read(clockProvider)(),
  );
  late DateTime _day = _days.tomorrow;
  DateTime? _otherDay;
  late ClockTime _time = widget.defaultTime;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 18,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Text(
                  strings.cardSheetReviewSoon,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  strings.reviewSoonBody(widget.front),
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: [
                Text(
                  strings.reviewSoonDay,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
                Column(
                  spacing: 8,
                  children: [
                    _dayRow(
                      _dayChoice(strings.reviewSoonTomorrow, _days.tomorrow),
                      _dayChoice(
                        strings.reviewSoonDayAfter,
                        _days.dayAfterTomorrow,
                      ),
                    ),
                    _dayRow(
                      _dayChoice(strings.reviewSoonWeekend, _days.weekend),
                      _otherDayChoice(strings),
                    ),
                  ],
                ),
              ],
            ),
            _timeRow(strings, colors),
            if (_error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            FilledButton(onPressed: _add, child: Text(strings.reviewSoonAdd)),
          ],
        ),
      ),
    );
  }

  /// Two day choices side by side, both as tall as the taller one: a label
  /// that wraps, such as "Day after tomorrow", grows its row instead of being
  /// cut.
  Widget _dayRow(Widget first, Widget second) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Expanded(child: first),
        Expanded(child: second),
      ],
    ),
  );

  Widget _dayChoice(String label, DateTime day) => ChoiceTile(
    label: label,
    detail: AppLocalizations.of(context).dayDate(day),
    isSelected: _otherDay == null && _day == day,
    onTap: () => setState(() {
      _day = day;
      _otherDay = null;
    }),
  );

  Widget _otherDayChoice(AppLocalizations strings) => ChoiceTile(
    label: strings.reviewSoonOtherDate,
    detail: _otherDay == null ? null : strings.dayDate(_otherDay!),
    isSelected: _otherDay != null,
    onTap: () async {
      final picked = await showDatePicker(
        context: context,
        initialDate: _days.tomorrow,
        firstDate: _days.tomorrow.subtract(const Duration(days: 1)),
        lastDate: _days.tomorrow.add(const Duration(days: 365)),
      );
      if (picked != null) {
        setState(() {
          _day = picked;
          _otherDay = picked;
        });
      }
    },
  );

  Widget _timeRow(AppLocalizations strings, AlambicColors colors) => InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: () async {
      final picked = await showTimePicker(
        context: context,
        initialTime: _time.toTimeOfDay(),
      );
      if (picked != null) {
        setState(() => _time = picked.toClockTime());
      }
    },
    child: Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.well,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        spacing: 12,
        children: [
          Icon(Icons.schedule, size: 20, color: colors.textSecondary),
          Expanded(
            child: Text(
              strings.reviewSoonTime,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            _time.toString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    ),
  );

  Future<void> _add() async {
    final calendar = ref.read(schedulingCalendarProvider);
    try {
      await ref.read(reminderServiceProvider).add(widget.cardId, _day, _time);
      if (mounted) {
        Navigator.of(context).pop(calendar.momentAt(_day, _time));
      }
    } on ArgumentError {
      setState(() => _error = AppLocalizations.of(context).reviewSoonPast);
    }
  }
}
