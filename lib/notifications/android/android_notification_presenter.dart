import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../application/notifications/answer_reveal.dart';
import '../../application/notifications/group_reminder.dart';
import '../../application/notifications/group_reminder_key.dart';
import '../../application/notifications/notification_digest.dart';
import '../../application/notifications/notification_action.dart';
import '../../application/notifications/notification_presenter.dart';
import '../../application/notifications/review_notification_key.dart';
import '../../application/notifications/review_prompt.dart';
import '../../data/images/image_store.dart';
import '../review_texts.dart';
import 'notification_payload.dart';

/// Review notifications on Android: the asked face as title, the step as
/// text, the group as sub-text, and the answer buttons handled in the
/// background without opening the app. A face with an image shows it once
/// the notification is expanded.
class AndroidNotificationPresenter implements NotificationPresenter {
  AndroidNotificationPresenter(this._plugin, this._texts, this._images);

  static const String channelId = 'reviews';

  /// Ids of extra reminders start here, above any direction id, so that an
  /// extra reminder never replaces the notification of a due card.
  static const int _extraReminderIdBase = 1000000000;

  /// The digest is a single notification, above any extra reminder.
  static const int _digestId = 2000000000;

  final AndroidFlutterLocalNotificationsPlugin _plugin;
  final ReviewTexts _texts;
  final ImageStore _images;

  @override
  Future<bool> requestPermission() async =>
      await _plugin.requestNotificationsPermission() ?? false;

  @override
  Future<void> showPrompt(ReviewPrompt prompt) {
    final title = _texts.promptTitle(prompt.prompt);
    final detail = _texts.promptDetail(prompt);
    return _plugin.show(
      id: _idOf(prompt.key),
      title: title,
      body: detail,
      payload: NotificationPayload.encode(prompt.key, isPrompt: true),
      notificationDetails: _details(
        subText: _texts.groupLabel(prompt),
        style: _picture(prompt.image, title: title, summary: detail),
        // A chained card follows the answer of the previous one.
        onlyAlertOnce: prompt.key.chain != null,
        actions: [
          if (prompt.typedAnswer)
            // Kept on screen, like "Again": the notification is replaced by
            // the expected answer.
            AndroidNotificationAction(
              NotificationAction.answer.name,
              _texts.strings.notificationAnswerButton,
              cancelNotification: false,
              inputs: [
                AndroidNotificationActionInput(
                  label: _texts.strings.notificationAnswerField,
                ),
              ],
            )
          else
            AndroidNotificationAction(
              NotificationAction.correct.name,
              _texts.strings.reviewCorrect,
              // A chained card is replaced by the next one.
              cancelNotification: prompt.key.chain == null,
            ),
          // Kept on screen: the notification is replaced by the answer.
          AndroidNotificationAction(
            NotificationAction.again.name,
            _texts.strings.reviewAgain,
            cancelNotification: false,
          ),
          if (prompt.key.chain != null)
            AndroidNotificationAction(
              NotificationAction.open.name,
              _texts.strings.notificationOpen,
              showsUserInterface: true,
            ),
        ],
      ),
    );
  }

  @override
  Future<void> showReveal(AnswerReveal reveal) {
    final answer = _texts.answerLine(reveal);
    final verdict = _texts.verdict(reveal);
    return _plugin.show(
      id: _idOf(reveal.key),
      title: _texts.promptTitle(reveal.prompt),
      body: answer,
      payload: NotificationPayload.encode(reveal.key, isPrompt: false),
      notificationDetails: _details(
        style:
            _picture(reveal.answerImage, title: answer, summary: verdict) ??
            BigTextStyleInformation('$answer\n$verdict'),
        onlyAlertOnce: true,
        actions: [
          AndroidNotificationAction(
            NotificationAction.acknowledge.name,
            _texts.strings.commonOk,
            // A chained card is replaced by the next one.
            cancelNotification: reveal.key.chain == null,
          ),
        ],
      ),
    );
  }

  @override
  Future<void> dismiss(ReviewNotificationKey key) =>
      _plugin.cancel(id: _idOf(key));

  @override
  Future<List<ReviewNotificationKey>> shownPrompts() async => [
    for (final notification in await _plugin.getActiveNotifications())
      ?NotificationPayload.decodePrompt(notification.payload),
  ];

  @override
  Future<void> showGroupReminder(GroupReminder reminder) => _plugin.show(
    id: _groupIdOf(reminder.key),
    title: _texts.groupReminderTitle(reminder),
    body: _texts.groupReminderDetail(reminder),
    payload: NotificationPayload.encodeGroup(reminder),
    notificationDetails: _details(
      onlyAlertOnce: !reminder.alert,
      silent: !reminder.alert,
      actions: [
        if (reminder.chain)
          // Kept on screen: the notification is replaced by the first card.
          AndroidNotificationAction(
            NotificationAction.start.name,
            _texts.strings.notificationStartHere,
            cancelNotification: false,
          ),
        AndroidNotificationAction(
          NotificationAction.open.name,
          _texts.strings.notificationOpenApp,
          showsUserInterface: true,
        ),
      ],
    ),
  );

  @override
  Future<void> dismissGroupReminder(GroupReminderKey key) =>
      _plugin.cancel(id: _groupIdOf(key));

  @override
  Future<Map<GroupReminderKey, int>> shownGroupReminders() async => {
    for (final notification in await _plugin.getActiveNotifications())
      ?NotificationPayload.decodeGroup(notification.payload):
          NotificationPayload.decodeGroupCount(notification.payload),
  };

  @override
  Future<void> showDigest(NotificationDigest digest) => _plugin.show(
    id: _digestId,
    title: _texts.digestTitle(digest),
    body: _texts.digestDetail(digest),
    payload: NotificationPayload.encodeDigest(digest),
    notificationDetails: _details(
      onlyAlertOnce: !digest.alert,
      silent: !digest.alert,
      actions: [
        AndroidNotificationAction(
          NotificationAction.open.name,
          _texts.strings.notificationOpenApp,
          showsUserInterface: true,
        ),
      ],
    ),
  );

  @override
  Future<void> dismissDigest() => _plugin.cancel(id: _digestId);

  @override
  Future<int?> shownDigestCount() async => [
    for (final notification in await _plugin.getActiveNotifications())
      ?NotificationPayload.decodeDigestCount(notification.payload),
  ].firstOrNull;

  /// A card chained in a grouped reminder takes the place of the reminder.
  static int _idOf(ReviewNotificationKey key) {
    final chain = key.chain;
    final extraReminderId = key.extraReminderId;
    if (chain != null) {
      return _groupIdOf(chain);
    } else if (extraReminderId != null) {
      return _extraReminderIdBase + extraReminderId;
    } else {
      return key.directionId;
    }
  }

  /// Grouped reminders use negative ids, which no card or extra reminder
  /// uses; "No group" is -1.
  static int _groupIdOf(GroupReminderKey key) => -1 - (key.groupId ?? 0);

  /// The image named [image] in the expanded notification, with [title] and
  /// [summary] in place of the title and text; `null` without an image, or
  /// when its file is gone.
  StyleInformation? _picture(
    String? image, {
    required String title,
    required String summary,
  }) {
    final path = image == null ? null : _images.pathOf(image);
    if (path == null || !File(path).existsSync()) {
      return null;
    }
    return BigPictureStyleInformation(
      FilePathAndroidBitmap(path),
      contentTitle: title,
      summaryText: summary,
    );
  }

  AndroidNotificationDetails _details({
    String? subText,
    StyleInformation? style,
    bool onlyAlertOnce = false,
    bool silent = false,
    required List<AndroidNotificationAction> actions,
  }) => AndroidNotificationDetails(
    channelId,
    _texts.strings.notificationChannelName,
    channelDescription: _texts.strings.notificationChannelDescription,
    importance: Importance.high,
    priority: Priority.high,
    category: AndroidNotificationCategory.reminder,
    subText: subText,
    styleInformation: style,
    onlyAlertOnce: onlyAlertOnce,
    silent: silent,
    actions: actions,
  );
}
