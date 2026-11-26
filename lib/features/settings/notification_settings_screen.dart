import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/formatting/reminder_settings_labels.dart';
import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/settings_group.dart';
import '../../application/distillation/distillation_providers.dart';
import '../../application/notifications/guard_providers.dart';
import '../../application/notifications/notification_presenter.dart';
import '../../application/notifications/notification_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../pauses/global_pause_dialog.dart';
import 'exact_alarms_row.dart';
import 'notification_mode_screen.dart';
import 'notifications_permission_row.dart';
import 'open_settings_screen.dart';
import 'reminder_schedule_screen.dart';
import 'settings_page.dart';

/// Everything that decides when and how the app notifies: the schedule, the
/// notification mode and the global pause of the distillations, then under
/// "Permissions" the notifications themselves, the exact alarms and a test
/// notification.
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
    final pausedAt = ref.watch(globalPauseProvider).value;
    final notificationsKnown =
        ref.watch(notificationsAllowedProvider).value != null;
    final exactAlarmsKnown =
        ref.watch(exactAlarmsAllowedProvider).value != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsGroup(
          children: [
            PanelRow(
              title: strings.scheduleTitle,
              value: reminders == null
                  ? null
                  : strings.scheduleLabel(reminders),
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
          ],
        ),
        const SizedBox(height: 24),
        SectionLabel(strings.settingsPermissionsSection),
        SettingsGroup(
          children: [
            if (notificationsKnown) const NotificationsPermissionRow(),
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
        ),
      ],
    );
  }
}
