import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/formatting/reminder_settings_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/settings_group.dart';
import '../../application/distillation/distillation_providers.dart';
import '../../application/notifications/guard_providers.dart';
import '../../application/notifications/notification_presenter.dart';
import '../../application/notifications/notification_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../pauses/global_pause_dialog.dart';
import 'exact_alarms_row.dart';
import 'notification_guards_screen.dart';
import 'notification_mode_screen.dart';
import 'open_settings_screen.dart';
import 'reminder_schedule_screen.dart';
import 'settings_page.dart';

/// Everything that decides when and how the app notifies: the schedule, the
/// notification mode, the safeguards, the exact alarms, and the global pause
/// of the distillations.
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => SettingsPage(
    title: AppLocalizations.of(context).settingsNotifications,
    children: const [_NotificationsPanel()],
  );
}

class _NotificationsPanel extends ConsumerWidget {
  const _NotificationsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final reminders = ref.watch(reminderSettingsProvider).value;
    final guards = ref.watch(notificationGuardsProvider).value;
    final pausedAt = ref.watch(globalPauseProvider).value;
    final exactAlarmsKnown =
        ref.watch(exactAlarmsAllowedProvider).value != null;
    return SettingsGroup(
      children: [
        PanelRow(
          title: strings.scheduleTitle,
          value: reminders == null ? null : strings.scheduleLabel(reminders),
          onTap: () =>
              openSettingsScreen(context, const ReminderScheduleScreen()),
        ),
        PanelRow(
          title: strings.notificationModeTitle,
          value: reminders == null
              ? null
              : strings.notificationModeLabel(reminders),
          onTap: () =>
              openSettingsScreen(context, const NotificationModeScreen()),
        ),
        PanelRow(
          title: strings.settingsGuards,
          subtitle: switch (guards) {
            null => null,
            final guards when guards.quietHoursEnabled =>
              strings.settingsGuardsSummary(
                guards.dailyCap,
                '${guards.quietStart}',
                '${guards.quietEnd}',
              ),
            final guards => strings.settingsGuardsSummaryNoQuiet(
              guards.dailyCap,
            ),
          },
          onTap: () =>
              openSettingsScreen(context, const NotificationGuardsScreen()),
        ),
        PanelRow(
          title: strings.pauseGlobal,
          subtitle: pausedAt == null
              ? strings.pauseGlobalHint
              : strings.pausedSince(strings.shortDate(pausedAt)),
          trailing: Switch(
            value: pausedAt != null,
            onChanged: (paused) => paused
                ? confirmGlobalPause(context, ref)
                : ref.read(distillationServiceProvider).resumeAll(),
          ),
        ),
        if (exactAlarmsKnown) const ExactAlarmsRow(),
        PanelRow(
          title: strings.testNotification,
          subtitle: strings.settingsTestNotificationHint,
          trailing: Icon(
            Icons.notifications_active_outlined,
            color: AlambicColors.of(context).textSecondary,
          ),
          onTap: () => ref.read(notificationPresenterProvider).sendTest(),
        ),
      ],
    );
  }
}
