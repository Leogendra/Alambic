import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/formatting/clock_time_conversions.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/count_stepper.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/notifications/guard_providers.dart';
import '../../domain/notifications/notification_guards.dart';
import '../../domain/scheduling/clock_time.dart';
import '../../l10n/generated/app_localizations.dart';

/// "Garde-fous": the daily cap with tomorrow's load, the quiet hours and the
/// auto grouping. Each change is saved at once.
class NotificationGuardsScreen extends ConsumerWidget {
  const NotificationGuardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final guards = ref.watch(notificationGuardsProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(strings.guardsTitle)),
      body: guards == null
          ? const SizedBox.shrink()
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _DailyCapPanel(guards: guards),
                const SizedBox(height: 14),
                _QuietHoursPanel(guards: guards),
                const SizedBox(height: 14),
                _AutoGroupPanel(guards: guards),
              ],
            ),
    );
  }
}

Future<void> _save(WidgetRef ref, NotificationGuards guards) =>
    ref.read(notificationSettingsServiceProvider).saveGuards(guards);

class _DailyCapPanel extends ConsumerWidget {
  const _DailyCapPanel({required this.guards});

  final NotificationGuards guards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final tomorrow = ref.watch(tomorrowDueCountProvider);
    return SurfacePanel(
      children: [
        PanelRow(
          title: strings.guardsDailyCap,
          subtitle: strings.guardsDailyCapHint,
          trailing: CountStepper(
            value: guards.dailyCap,
            label: '${guards.dailyCap}',
            decreaseTooltip: strings.guardsDecrease,
            increaseTooltip: strings.guardsIncrease,
            onChanged: (cap) => _save(ref, guards.copyWith(dailyCap: cap)),
          ),
        ),
        if (tomorrow != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _TomorrowLoad(due: tomorrow, cap: guards.dailyCap),
          ),
      ],
    );
  }
}

/// Tomorrow's due cards against the cap: those sent, those moved to the day
/// after.
class _TomorrowLoad extends StatelessWidget {
  const _TomorrowLoad({required this.due, required this.cap});

  final int due;
  final int cap;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final sent = due < cap ? due : cap;
    final postponed = due - sent;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.well,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          Text(
            strings.guardsTomorrow(due),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          if (due > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SizedBox(
                height: 10,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 2,
                  children: [
                    Expanded(
                      flex: sent,
                      child: ColoredBox(color: colors.accent),
                    ),
                    if (postponed > 0)
                      Expanded(
                        flex: postponed,
                        child: ColoredBox(color: colors.border),
                      ),
                  ],
                ),
              ),
            ),
          if (due > 0)
            Text(
              postponed == 0
                  ? strings.guardsTomorrowAllSent
                  : strings.guardsTomorrowSplit(sent, postponed),
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: colors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _QuietHoursPanel extends ConsumerWidget {
  const _QuietHoursPanel({required this.guards});

  final NotificationGuards guards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return SurfacePanel(
      children: [
        PanelRow(
          title: strings.guardsQuietHours,
          subtitle: strings.guardsQuietHoursHint,
          trailing: Switch(
            value: guards.quietHoursEnabled,
            onChanged: (enabled) =>
                _save(ref, guards.copyWith(quietHoursEnabled: enabled)),
          ),
        ),
        if (guards.quietHoursEnabled)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              spacing: 8,
              children: [
                Expanded(
                  child: _TimeButton(
                    label: strings.guardsQuietFrom,
                    time: guards.quietStart,
                    onPicked: (time) =>
                        _save(ref, guards.copyWith(quietStart: time)),
                  ),
                ),
                Expanded(
                  child: _TimeButton(
                    label: strings.guardsQuietTo,
                    time: guards.quietEnd,
                    onPicked: (time) =>
                        _save(ref, guards.copyWith(quietEnd: time)),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// "De 22:00": a time of the quiet hours, changed with the time picker.
class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.time,
    required this.onPicked,
  });

  final String label;
  final ClockTime time;
  final ValueChanged<ClockTime> onPicked;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return Material(
      color: colors.well,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: time.toTimeOfDay(),
          );
          if (picked != null) {
            onPicked(picked.toClockTime());
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 2,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
              Text(
                '$time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AutoGroupPanel extends ConsumerWidget {
  const _AutoGroupPanel({required this.guards});

  final NotificationGuards guards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return SurfacePanel(
      children: [
        PanelRow(
          title: strings.guardsAutoGroup,
          subtitle: strings.guardsAutoGroupHint,
          trailing: Switch(
            value: guards.autoGroupEnabled,
            onChanged: (enabled) =>
                _save(ref, guards.copyWith(autoGroupEnabled: enabled)),
          ),
        ),
        if (guards.autoGroupEnabled)
          PanelRow(
            title: strings.guardsAutoGroupThreshold,
            trailing: CountStepper(
              value: guards.autoGroupThreshold,
              label: '${guards.autoGroupThreshold}',
              decreaseTooltip: strings.guardsDecrease,
              increaseTooltip: strings.guardsIncrease,
              onChanged: (threshold) =>
                  _save(ref, guards.copyWith(autoGroupThreshold: threshold)),
            ),
          ),
      ],
    );
  }
}
