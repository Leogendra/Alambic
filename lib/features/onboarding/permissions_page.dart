import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/notifications/guard_providers.dart';
import '../../application/notifications/notification_providers.dart';
import '../../domain/notifications/reminder_settings.dart';
import '../../domain/scheduling/clock_time.dart';
import '../../l10n/generated/app_localizations.dart';
import 'onboarding_page.dart';

/// Second screen: the right to post notifications, exact alarms, and the time
/// of the reminders, written into the schedule of the app.
///
/// Exact alarms are allowed from a system settings page; the permission is
/// read again when the app comes back to the front.
class PermissionsPage extends ConsumerStatefulWidget {
  const PermissionsPage({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  ConsumerState<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends ConsumerState<PermissionsPage> {
  late final AppLifecycleListener _lifecycle;
  bool _notificationsAllowed = false;
  ClockTime _time = ReminderSettings.defaults.fixedTime;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(exactAlarmsAllowedProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _allowNotifications() async {
    final allowed = await ref
        .read(notificationPresenterProvider)
        .requestPermission();
    if (mounted) {
      setState(() => _notificationsAllowed = allowed);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _time.hour, minute: _time.minute),
    );
    if (picked != null) {
      setState(() => _time = ClockTime(picked.hour, picked.minute));
    }
  }

  Future<void> _continue() async {
    // A fresh database is already at the default time.
    if (_time != ReminderSettings.defaults.fixedTime) {
      await ref.read(notificationSettingsServiceProvider).setFixedTime(_time);
    }
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final exactAllowed = ref.watch(exactAlarmsAllowedProvider).value ?? false;
    return OnboardingPage(
      step: 1,
      title: strings.onboardingPermissionsTitle,
      body: strings.onboardingPermissionsBody,
      action: FilledButton(
        onPressed: _continue,
        child: Text(strings.onboardingNext),
      ),
      child: SurfacePanel(
        children: [
          PanelRow(
            title: strings.onboardingNotifications,
            subtitle: strings.onboardingNotificationsHint,
            trailing: _PermissionButton(
              allowed: _notificationsAllowed,
              onPressed: _allowNotifications,
            ),
          ),
          PanelRow(
            title: strings.onboardingExactAlarms,
            subtitle: strings.onboardingExactAlarmsHint,
            trailing: _PermissionButton(
              allowed: exactAllowed,
              onPressed: () =>
                  ref.read(alarmSchedulerProvider).requestExactPermission(),
            ),
          ),
          PanelRow(
            title: strings.onboardingTime,
            subtitle: strings.onboardingTimeHint,
            value: '$_time',
            onTap: _pickTime,
          ),
        ],
      ),
    );
  }
}

/// "Allow", or "Allowed" once the permission is given.
class _PermissionButton extends StatelessWidget {
  const _PermissionButton({required this.allowed, required this.onPressed});

  final bool allowed;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    if (allowed) {
      return Text(
        strings.onboardingAllowed,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AlambicColors.of(context).textSecondary,
        ),
      );
    } else {
      return FilledButton.tonal(
        // The theme stretches buttons to the full width; this one sits at the
        // end of a row.
        style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
        onPressed: onPressed,
        child: Text(strings.onboardingAllow),
      );
    }
  }
}
