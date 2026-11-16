import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/formatting/clock_time_conversions.dart';
import '../../app/layout/scroll_padding.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/segment_option.dart';
import '../../app/widgets/segmented_choice.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/notifications/guard_providers.dart';
import '../../domain/notifications/reminder_settings.dart';
import '../../domain/notifications/schedule_kind.dart';
import '../../domain/scheduling/clock_time.dart';
import '../../l10n/generated/app_localizations.dart';

/// "Horaire": a fixed time or a time range, for every group. Each change is
/// saved at once.
class ReminderScheduleScreen extends ConsumerWidget {
  const ReminderScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final reminders = ref.watch(reminderSettingsProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(strings.scheduleTitle)),
      body: reminders == null
          ? const SizedBox.shrink()
          : ListView(
              padding: scrollPadding(
                context,
                const EdgeInsets.fromLTRB(20, 8, 20, 32),
              ),
              children: [
                SegmentedChoice<ScheduleKind>(
                  options: [
                    SegmentOption(
                      ScheduleKind.fixedTime,
                      strings.scheduleFixed,
                    ),
                    SegmentOption(
                      ScheduleKind.timeRange,
                      strings.scheduleRange,
                    ),
                  ],
                  selected: reminders.scheduleKind,
                  onSelected: (kind) =>
                      _save(ref, reminders.copyWith(scheduleKind: kind)),
                ),
                const SizedBox(height: 14),
                SurfacePanel(children: _timeRows(context, ref, reminders)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
                  child: Text(
                    switch (reminders.scheduleKind) {
                      ScheduleKind.fixedTime => strings.scheduleHint,
                      ScheduleKind.timeRange =>
                        '${strings.scheduleRangeHint} ${strings.scheduleHint}',
                    },
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  List<Widget> _timeRows(
    BuildContext context,
    WidgetRef ref,
    ReminderSettings reminders,
  ) {
    final strings = AppLocalizations.of(context);
    return switch (reminders.scheduleKind) {
      ScheduleKind.fixedTime => [
        _timeRow(
          context,
          strings.scheduleFixedTime,
          reminders.fixedTime,
          (time) => _save(ref, reminders.copyWith(fixedTime: time)),
        ),
      ],
      ScheduleKind.timeRange => [
        _timeRow(
          context,
          strings.scheduleRangeStart,
          reminders.rangeStart,
          (time) => _save(ref, reminders.copyWith(rangeStart: time)),
        ),
        _timeRow(
          context,
          strings.scheduleRangeEnd,
          reminders.rangeEnd,
          (time) => _save(ref, reminders.copyWith(rangeEnd: time)),
        ),
      ],
    };
  }

  Widget _timeRow(
    BuildContext context,
    String title,
    ClockTime time,
    ValueChanged<ClockTime> onPicked,
  ) => PanelRow(
    title: title,
    value: time.toString(),
    onTap: () async {
      final picked = await showTimePicker(
        context: context,
        initialTime: time.toTimeOfDay(),
      );
      if (picked != null) {
        onPicked(picked.toClockTime());
      }
    },
  );

  Future<void> _save(WidgetRef ref, ReminderSettings reminders) => ref
      .read(notificationSettingsServiceProvider)
      .saveReminderSettings(reminders);
}
