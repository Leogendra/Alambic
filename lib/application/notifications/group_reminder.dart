import 'group_reminder_key.dart';

/// Content of a grouped reminder: "Capitales : 5 cartes à réviser".
class GroupReminder {
  const GroupReminder({
    required this.key,
    required this.groupName,
    required this.count,
    required this.chain,
    required this.alert,
  });

  final GroupReminderKey key;

  /// `null` for "No group".
  final String? groupName;

  /// Due cards waiting in the reminder.
  final int count;

  /// Offers to chain the cards inside the notification, besides opening the
  /// app on the group.
  final bool chain;

  /// Rings and vibrates; `false` when only the count of a reminder already
  /// shown is refreshed.
  final bool alert;
}
