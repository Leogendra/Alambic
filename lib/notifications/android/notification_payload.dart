import 'dart:convert';

import '../../application/notifications/group_reminder.dart';
import '../../application/notifications/group_reminder_key.dart';
import '../../application/notifications/notification_digest.dart';
import '../../application/notifications/notification_target.dart';
import '../../application/notifications/review_notification_key.dart';
import '../../domain/cards/card_side.dart';

/// The key of a notification, carried in its payload so that a pressed
/// button knows what it answers: a card and the face it asks, possibly
/// chained in a grouped reminder, the count of a grouped reminder, or the
/// digest of a moment.
abstract final class NotificationPayload {
  static String encode(
    ReviewNotificationKey key, {
    required bool isPrompt,
    required CardSide askedSide,
  }) {
    final chain = key.chain;
    return jsonEncode({
      'card': key.cardId,
      'side': askedSide.name,
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

  static String encodeDigest(NotificationDigest digest) =>
      jsonEncode({'digest': true, 'count': digest.count});

  /// The count shown by the digest, `null` for any other notification.
  static int? decodeDigestCount(String? payload) {
    final fields = _fields(payload);
    return fields != null && fields['digest'] == true
        ? fields['count'] as int?
        : null;
  }

  /// `null` for a payload that is not a card notification.
  static ReviewNotificationKey? decode(String? payload) {
    final fields = _fields(payload);
    return fields == null || fields['card'] is! int ? null : _key(fields);
  }

  /// The face asked by a card notification; the front when the payload does
  /// not say.
  static CardSide askedSide(String? payload) =>
      CardSide.values
          .where((side) => side.name == _fields(payload)?['side'])
          .firstOrNull ??
      CardSide.front;

  /// Like [decode], but only for cards not answered yet.
  static ReviewNotificationKey? decodePrompt(String? payload) {
    final fields = _fields(payload);
    return fields != null && fields['card'] is int && fields['prompt'] == true
        ? _key(fields)
        : null;
  }

  /// `null` for a payload that is not the count of a grouped reminder.
  static GroupReminderKey? decodeGroup(String? payload) {
    final fields = _fields(payload);
    return fields != null && fields['summary'] == true
        ? GroupReminderKey(fields['group'] as int)
        : null;
  }

  /// The count shown by a grouped reminder, `0` for any other notification.
  static int decodeGroupCount(String? payload) =>
      _fields(payload)?['count'] as int? ?? 0;

  /// The group to open for a grouped reminder or a card chained in it, Home
  /// for the digest; `null` for any other notification.
  static NotificationTarget? target(String? payload) {
    final fields = _fields(payload);
    if (fields == null) {
      return null;
    } else if (fields['digest'] == true) {
      return const NotificationTarget.home();
    } else if (fields['summary'] == true || fields['chained'] == true) {
      return NotificationTarget.group(fields['group'] as int);
    } else {
      return null;
    }
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
        cardId: fields['card'] as int,
        extraReminderId: fields['reminder'] as int?,
        chain: fields['chained'] == true
            ? GroupReminderKey(fields['group'] as int)
            : null,
      );
}
