import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../application/notifications/answer_reveal.dart';
import '../../application/notifications/notification_action.dart';
import '../../application/notifications/notification_presenter.dart';
import '../../application/notifications/review_notification_key.dart';
import '../../application/notifications/review_prompt.dart';
import '../review_texts.dart';
import 'notification_payload.dart';

/// Review notifications on Android: the asked face as title, the step as
/// text, the group as sub-text, and the answer buttons handled in the
/// background without opening the app.
class AndroidNotificationPresenter implements NotificationPresenter {
  AndroidNotificationPresenter(this._plugin, this._texts);

  static const String channelId = 'reviews';

  /// Ids of extra reminders start here, above any direction id, so that an
  /// extra reminder never replaces the notification of a due card.
  static const int _extraReminderIdBase = 1000000000;

  final AndroidFlutterLocalNotificationsPlugin _plugin;
  final ReviewTexts _texts;

  @override
  Future<void> requestPermission() => _plugin.requestNotificationsPermission();

  @override
  Future<void> showPrompt(ReviewPrompt prompt) => _plugin.show(
    id: _idOf(prompt.key),
    title: prompt.prompt,
    body: _texts.promptDetail(prompt),
    payload: NotificationPayload.encode(prompt.key, isPrompt: true),
    notificationDetails: _details(
      subText: _texts.groupLabel(prompt),
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
          ),
        // Kept on screen: the notification is replaced by the answer.
        AndroidNotificationAction(
          NotificationAction.again.name,
          _texts.strings.reviewAgain,
          cancelNotification: false,
        ),
      ],
    ),
  );

  @override
  Future<void> showReveal(AnswerReveal reveal) {
    final answer = _texts.answerLine(reveal);
    return _plugin.show(
      id: _idOf(reveal.key),
      title: reveal.prompt,
      body: answer,
      payload: NotificationPayload.encode(reveal.key, isPrompt: false),
      notificationDetails: _details(
        bigText: '$answer\n${_texts.verdict(reveal)}',
        onlyAlertOnce: true,
        actions: [
          AndroidNotificationAction(
            NotificationAction.acknowledge.name,
            _texts.strings.commonOk,
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

  static int _idOf(ReviewNotificationKey key) {
    final extraReminderId = key.extraReminderId;
    return extraReminderId == null
        ? key.directionId
        : _extraReminderIdBase + extraReminderId;
  }

  AndroidNotificationDetails _details({
    String? subText,
    String? bigText,
    bool onlyAlertOnce = false,
    required List<AndroidNotificationAction> actions,
  }) => AndroidNotificationDetails(
    channelId,
    _texts.strings.notificationChannelName,
    channelDescription: _texts.strings.notificationChannelDescription,
    importance: Importance.high,
    priority: Priority.high,
    category: AndroidNotificationCategory.reminder,
    subText: subText,
    styleInformation: bigText == null ? null : BigTextStyleInformation(bigText),
    onlyAlertOnce: onlyAlertOnce,
    actions: actions,
  );
}
