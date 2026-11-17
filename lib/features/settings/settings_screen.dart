import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/formatting/date_labels.dart';
import '../../app/formatting/reminder_settings_labels.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/notifications/guard_providers.dart';
import '../../application/pauses/pause_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../presets/presets_screen.dart';
import 'backup_panel.dart';
import 'display_panel.dart';
import 'exact_alarms_panel.dart';
import 'notification_guards_screen.dart';
import 'notification_mode_screen.dart';
import 'reminder_schedule_screen.dart';

/// Settings tab.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 20),
          child: Text(
            strings.settingsTitle,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
        ),
        SectionLabel(strings.settingsNotificationsSection),
        const _NotificationsPanel(),
        const SizedBox(height: 14),
        const ExactAlarmsPanel(),
        const SizedBox(height: 24),
        SectionLabel(strings.settingsPresetsSection),
        const _PresetsPanel(),
        const SizedBox(height: 24),
        SectionLabel(strings.settingsDisplaySection),
        const DisplayPanel(),
        const SizedBox(height: 24),
        SectionLabel(strings.settingsDataSection),
        const BackupPanel(),
      ],
    );
  }
}

class _PresetsPanel extends StatelessWidget {
  const _PresetsPanel();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SurfacePanel(
      children: [
        PanelRow(
          title: strings.settingsPresets,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => const PresetsScreen(),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationsPanel extends ConsumerWidget {
  const _NotificationsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final reminders = ref.watch(reminderSettingsProvider).value;
    final guards = ref.watch(notificationGuardsProvider).value;
    final pausedAt = ref.watch(pausesProvider).value?.globalSince;
    return SurfacePanel(
      children: [
        PanelRow(
          title: strings.scheduleTitle,
          value: reminders == null ? null : strings.scheduleLabel(reminders),
          onTap: () => _open(context, const ReminderScheduleScreen()),
        ),
        PanelRow(
          title: strings.notificationModeTitle,
          value: reminders == null
              ? null
              : strings.notificationModeLabel(reminders),
          onTap: () => _open(context, const NotificationModeScreen()),
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
          onTap: () => _open(context, const NotificationGuardsScreen()),
        ),
        PanelRow(
          title: strings.pauseGlobal,
          subtitle: pausedAt == null
              ? strings.pauseGlobalHint
              : strings.pausedSince(strings.shortDate(pausedAt)),
          trailing: Switch(
            value: pausedAt != null,
            onChanged: (paused) {
              final service = ref.read(pauseServiceProvider);
              paused ? service.pauseAll() : service.resumeAll();
            },
          ),
        ),
      ],
    );
  }
}

Future<void> _open(BuildContext context, Widget screen) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (context) => screen));
