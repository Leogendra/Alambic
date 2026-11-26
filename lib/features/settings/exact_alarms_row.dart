import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/notifications/notification_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'permission_row.dart';

/// Whether reminders fire at the exact minute. Without the permission they
/// still fire, a few minutes late at most, and the row offers to allow it
/// with a button opening the system settings page. Back in the app, the
/// permission is read again and every wake-up is rescheduled when it changed.
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
    return PermissionRow(
      title: strings.settingsExactAlarms,
      allowed: allowed,
      allowedHint: strings.settingsExactAlarmsOn,
      refusedHint: strings.settingsExactAlarmsOff,
      onAllow: () => ref.read(alarmSchedulerProvider).requestExactPermission(),
    );
  }
}
