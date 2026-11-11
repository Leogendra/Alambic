import 'dart:convert';

import '../../application/notifications/review_notification_key.dart';

/// The key of a review notification, carried in its payload so that a
/// pressed button knows which direction it answers. [decodePrompt] only
/// accepts card prompts, not revealed answers.
abstract final class NotificationPayload {
  static String encode(ReviewNotificationKey key, {required bool isPrompt}) =>
      jsonEncode({
        'direction': key.directionId,
        'reminder': key.extraReminderId,
        'prompt': isPrompt,
      });

  /// `null` for a payload that is not a review notification.
  static ReviewNotificationKey? decode(String? payload) {
    final fields = _fields(payload);
    return fields == null ? null : _key(fields);
  }

  static ReviewNotificationKey? decodePrompt(String? payload) {
    final fields = _fields(payload);
    return fields != null && fields['prompt'] == true ? _key(fields) : null;
  }

  static Map<String, dynamic>? _fields(String? payload) {
    if (payload == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> && decoded['direction'] is int
          ? decoded
          : null;
    } on FormatException {
      return null;
    }
  }

  static ReviewNotificationKey _key(Map<String, dynamic> fields) =>
      ReviewNotificationKey(
        directionId: fields['direction'] as int,
        extraReminderId: fields['reminder'] as int?,
      );
}
