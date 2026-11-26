import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../application/notifications/notification_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import 'permission_row.dart';

/// Whether the app may post notifications. Refused, no reminder shows, and
/// the row offers to allow them with a button opening the system page of the
/// app's notifications: once refused twice, Android no longer shows its
/// dialog. Back in the app, the permission is read again. Wake-ups go on
/// while it is refused, so nothing needs rescheduling.
class NotificationsPermissionRow extends ConsumerStatefulWidget {
  const NotificationsPermissionRow({super.key});

  @override
  ConsumerState<NotificationsPermissionRow> createState() =>
      _NotificationsPermissionRowState();
}

class _NotificationsPermissionRowState
    extends ConsumerState<NotificationsPermissionRow> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(notificationsAllowedProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final allowed = ref.watch(notificationsAllowedProvider).value;
    if (allowed == null) {
      return const SizedBox.shrink();
    }
    return PermissionRow(
      title: strings.settingsNotificationsPermission,
      allowed: allowed,
      allowedHint: strings.settingsNotificationsPermissionOn,
      refusedHint: strings.settingsNotificationsPermissionOff,
      onAllow: () =>
          ref.read(notificationPresenterProvider).openSystemSettings(),
    );
  }
}
