import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../app/widgets/panel_row.dart';
import '../../application/notifications/notification_providers.dart';
import '../../l10n/generated/app_localizations.dart';

/// Whether reminders fire at the exact minute. Without the permission they
/// still fire, a few minutes late at most, and the row offers to allow it with
/// a button opening the system settings page. Once allowed, the row only says
/// so: there is nothing to turn off. Back in the app, the permission is read
/// again and every wake-up is rescheduled when it changed.
class ExactAlarmsRow extends ConsumerStatefulWidget {
  const ExactAlarmsRow({super.key});

  @override
  ConsumerState<ExactAlarmsRow> createState() => _ExactAlarmsRowState();
}

class _ExactAlarmsRowState extends ConsumerState<ExactAlarmsRow> {
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
    final allowed = ref.watch(exactAlarmsAllowedProvider).value;
    if (allowed == null) {
      return const SizedBox.shrink();
    }
    if (allowed) {
      return PanelRow(
        title: strings.settingsExactAlarms,
        subtitle: strings.settingsExactAlarmsOn,
        trailing: Icon(
          Icons.check_circle,
          color: AlambicColors.of(context).accent,
        ),
      );
    }
    return PanelRow(
      title: strings.settingsExactAlarms,
      subtitle: strings.settingsExactAlarmsOff,
      trailing: FilledButton.tonal(
        style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
        onPressed: () =>
            ref.read(alarmSchedulerProvider).requestExactPermission(),
        child: Text(strings.settingsExactAlarmsAllow),
      ),
    );
  }
}
