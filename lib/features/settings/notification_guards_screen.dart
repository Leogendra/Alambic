import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/clock_time_conversions.dart';
import '../../app/layout/scroll_padding.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/count_stepper.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/settings_group.dart';
import '../../application/notifications/guard_providers.dart';
import '../../domain/notifications/notification_guards.dart';
import '../../domain/scheduling/clock_time.dart';
import '../../l10n/generated/app_localizations.dart';

/// "Garde-fous": the smoothing of the due dates, the quiet hours and the auto
/// grouping. Each change is saved at once.
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
              padding: scrollPadding(
                context,
                const EdgeInsets.fromLTRB(20, 8, 20, 32),
              ),
              children: [
                SettingsGroup(
                  children: [
                    _SmoothDueDatesSetting(guards: guards),
                    _QuietHoursSetting(guards: guards),
                    _AutoGroupSetting(guards: guards),
                    if (guards.autoGroupEnabled)
                      _AutoGroupThreshold(guards: guards),
                  ],
                ),
              ],
            ),
    );
  }
}

Future<void> _save(WidgetRef ref, NotificationGuards guards) =>
    ref.read(notificationSettingsServiceProvider).saveGuards(guards);

class _SmoothDueDatesSetting extends ConsumerWidget {
  const _SmoothDueDatesSetting({required this.guards});

  final NotificationGuards guards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return PanelRow(
      title: strings.guardsSmoothDueDates,
      subtitle: strings.guardsSmoothDueDatesHint,
      trailing: Switch(
        value: guards.smoothDueDates,
        onChanged: (enabled) =>
            _save(ref, guards.copyWith(smoothDueDates: enabled)),
      ),
    );
  }
}

class _QuietHoursSetting extends ConsumerWidget {
  const _QuietHoursSetting({required this.guards});

  final NotificationGuards guards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return Column(
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

class _AutoGroupSetting extends ConsumerWidget {
  const _AutoGroupSetting({required this.guards});

  final NotificationGuards guards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return PanelRow(
      title: strings.guardsAutoGroup,
      subtitle: strings.guardsAutoGroupHint,
      trailing: Switch(
        value: guards.autoGroupEnabled,
        onChanged: (enabled) =>
            _save(ref, guards.copyWith(autoGroupEnabled: enabled)),
      ),
    );
  }
}

class _AutoGroupThreshold extends ConsumerWidget {
  const _AutoGroupThreshold({required this.guards});

  final NotificationGuards guards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return PanelRow(
      title: strings.guardsAutoGroupThreshold,
      trailing: CountStepper(
        value: guards.autoGroupThreshold,
        label: '${guards.autoGroupThreshold}',
        decreaseTooltip: strings.guardsDecrease,
        increaseTooltip: strings.guardsIncrease,
        onChanged: (threshold) =>
            _save(ref, guards.copyWith(autoGroupThreshold: threshold)),
      ),
    );
  }
}
