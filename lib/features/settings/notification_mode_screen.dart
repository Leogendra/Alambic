import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/layout/scroll_padding.dart';
import '../../app/widgets/choice_tile.dart';
import '../../app/widgets/section_label.dart';
import '../../app/widgets/segment_option.dart';
import '../../app/widgets/segmented_choice.dart';
import '../../application/notifications/guard_providers.dart';
import '../../domain/notifications/grouped_reminder_action.dart';
import '../../domain/notifications/notification_mode.dart';
import '../../domain/notifications/reminder_settings.dart';
import '../../l10n/generated/app_localizations.dart';

/// "Mode de notification": one notification per card, or one grouped reminder
/// per group that opens the app or chains the cards. Each change is saved at
/// once.
class NotificationModeScreen extends ConsumerWidget {
  const NotificationModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final reminders = ref.watch(reminderSettingsProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(strings.notificationModeTitle)),
      body: reminders == null
          ? const SizedBox.shrink()
          : ListView(
              padding: scrollPadding(
                context,
                const EdgeInsets.fromLTRB(20, 8, 20, 32),
              ),
              children: [
                ChoiceTile(
                  label: strings.notificationModePerCard,
                  detail: strings.notificationModePerCardHint,
                  isSelected:
                      reminders.notificationMode == NotificationMode.perCard,
                  onTap: () => _save(
                    ref,
                    reminders.copyWith(
                      notificationMode: NotificationMode.perCard,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                ChoiceTile(
                  label: strings.notificationModeGrouped,
                  detail: strings.notificationModeGroupedHint,
                  isSelected:
                      reminders.notificationMode == NotificationMode.grouped,
                  onTap: () => _save(
                    ref,
                    reminders.copyWith(
                      notificationMode: NotificationMode.grouped,
                    ),
                  ),
                ),
                if (reminders.notificationMode == NotificationMode.grouped) ...[
                  const SizedBox(height: 24),
                  SectionLabel(strings.notificationModeGroupedTap),
                  SegmentedChoice<GroupedReminderAction>(
                    options: [
                      SegmentOption(
                        GroupedReminderAction.openApp,
                        strings.notificationModeOpenApp,
                      ),
                      SegmentOption(
                        GroupedReminderAction.chainInNotification,
                        strings.notificationModeChain,
                      ),
                    ],
                    selected: reminders.groupedAction,
                    onSelected: (action) =>
                        _save(ref, reminders.copyWith(groupedAction: action)),
                  ),
                ],
              ],
            ),
    );
  }

  Future<void> _save(WidgetRef ref, ReminderSettings reminders) => ref
      .read(notificationSettingsServiceProvider)
      .saveReminderSettings(reminders);
}
