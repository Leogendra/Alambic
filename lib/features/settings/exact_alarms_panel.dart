import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/remanence_colors.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/notifications/notification_providers.dart';
import '../../l10n/generated/app_localizations.dart';

/// Whether reminders fire at the exact minute. Without the permission they
/// still fire, a few minutes late at most, and the panel offers to allow it.
/// The system settings page opened for that returns to the app, which then
/// reads the permission again and reschedules every wake-up.
class ExactAlarmsPanel extends ConsumerStatefulWidget {
  const ExactAlarmsPanel({super.key});

  @override
  ConsumerState<ExactAlarmsPanel> createState() => _ExactAlarmsPanelState();
}

class _ExactAlarmsPanelState extends ConsumerState<ExactAlarmsPanel> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _onResume() async {
    final wasAllowed = ref.read(exactAlarmsAllowedProvider).value;
    final isAllowed = await ref.refresh(exactAlarmsAllowedProvider.future);
    if (wasAllowed != isAllowed) {
      await ref.read(notificationPlannerProvider).replan(force: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = RemanenceColors.of(context);
    final allowed = ref.watch(exactAlarmsAllowedProvider).value;
    if (allowed == null) {
      return const SizedBox.shrink();
    }
    if (allowed) {
      return SurfacePanel(
        children: [
          PanelRow(
            title: strings.settingsExactAlarms,
            subtitle: strings.settingsExactAlarmsOn,
            trailing: Text(
              strings.settingsExactAlarmsAllowed,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }
    return SurfacePanel(
      padding: const EdgeInsets.all(16),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 4,
          children: [
            Text(
              strings.settingsExactAlarms,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Text(
              strings.settingsExactAlarmsOff,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () =>
                  ref.read(alarmSchedulerProvider).requestExactPermission(),
              child: Text(strings.settingsExactAlarmsAllow),
            ),
          ],
        ),
      ],
    );
  }
}
