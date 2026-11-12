import 'dart:convert';

import '../../application/notifications/group_reminder.dart';
import '../../application/notifications/group_reminder_key.dart';
import '../../application/notifications/notification_target.dart';
import '../../application/notifications/review_notification_key.dart';

/// The key of a notification, carried in its payload so that a pressed
/// button knows what it answers: a card, possibly chained in a grouped
/// reminder, or the count of a grouped reminder.
abstract final class NotificationPayload {
  static String encode(ReviewNotificationKey key, {required bool isPrompt}) {
    final chain = key.chain;
    return jsonEncode({
      'direction': key.directionId,
      'reminder': key.extraReminderId,
      'prompt': isPrompt,
      if (chain != null) ...{'chained': true, 'group': chain.groupId},
    });
  }

  static String encodeGroup(GroupReminder reminder) => jsonEncode({
    'summary': true,
    'group': reminder.key.groupId,
    'count': reminder.count,
  });

  /// `null` for a payload that is not a card notification.
  static ReviewNotificationKey? decode(String? payload) {
    final fields = _fields(payload);
    return fields == null || fields['direction'] is! int ? null : _key(fields);
  }

  /// Like [decode], but only for cards not answered yet.
  static ReviewNotificationKey? decodePrompt(String? payload) {
    final fields = _fields(payload);
    return fields != null &&
            fields['direction'] is int &&
            fields['prompt'] == true
        ? _key(fields)
        : null;
  }

  /// `null` for a payload that is not the count of a grouped reminder.
  static GroupReminderKey? decodeGroup(String? payload) {
    final fields = _fields(payload);
    return fields != null && fields['summary'] == true
        ? GroupReminderKey(fields['group'] as int?)
        : null;
  }

  /// The count shown by a grouped reminder, `0` for any other notification.
  static int decodeGroupCount(String? payload) =>
      _fields(payload)?['count'] as int? ?? 0;

  /// The group to open for a grouped reminder or a card chained in it;
  /// `null` for any other notification.
  static NotificationTarget? target(String? payload) {
    final fields = _fields(payload);
    return fields != null &&
            (fields['summary'] == true || fields['chained'] == true)
        ? NotificationTarget.group(fields['group'] as int?)
        : null;
  }

  static Map<String, dynamic>? _fields(String? payload) {
    if (payload == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> ? decoded : null;
    } on FormatException {
      return null;
    }
  }

  static ReviewNotificationKey _key(Map<String, dynamic> fields) =>
      ReviewNotificationKey(
        directionId: fields['direction'] as int,
        extraReminderId: fields['reminder'] as int?,
        chain: fields['chained'] == true
            ? GroupReminderKey(fields['group'] as int?)
            : null,
      );
}
