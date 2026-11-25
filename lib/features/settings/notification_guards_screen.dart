import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/layout/scroll_padding.dart';
import '../../app/widgets/panel_row.dart';
import '../../app/widgets/settings_group.dart';
import '../../application/notifications/guard_providers.dart';
import '../../domain/notifications/notification_guards.dart';
import '../../l10n/generated/app_localizations.dart';

/// "Garde-fous": the smoothing of the due dates. Each change is saved at once.
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
                  children: [_SmoothDueDatesSetting(guards: guards)],
                ),
              ],
            ),
    );
  }
}

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
        onChanged: (enabled) => ref
            .read(notificationSettingsServiceProvider)
            .saveGuards(guards.copyWith(smoothDueDates: enabled)),
      ),
    );
  }
}
