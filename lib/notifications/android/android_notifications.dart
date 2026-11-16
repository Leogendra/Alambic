import 'dart:async';
import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../app/app_locale.dart';
import '../../application/clock.dart';
import '../../application/notifications/notification_providers.dart';
import '../../application/notifications/notification_target.dart';
import '../../application/preferences/interface_settings_providers.dart';
import '../../application/scheduling/scheduling_providers.dart';
import '../../data/data_providers.dart';
import '../../data/preferences/language_choice.dart';
import '../../l10n/generated/app_localizations.dart';
import '../review_texts.dart';
import '../shared_preferences_alarm_store.dart';
import 'android_alarm_scheduler.dart';
import 'android_notification_presenter.dart';
import 'background_entry_points.dart';
import 'notification_payload.dart';

/// Wiring of the Android notification layer, shared by the app and by the
/// background tasks, which each run in their own isolate.
abstract final class AndroidNotifications {
  static final AndroidFlutterLocalNotificationsPlugin _plugin =
      AndroidFlutterLocalNotificationsPlugin();

  static final StreamController<NotificationTarget> _opened =
      StreamController.broadcast();

  /// Initializes the plugins in the current isolate. Buttons pressed on a
  /// notification are always handled by [onNotificationResponse] in a
  /// background isolate, whether the app is open or not, except the ones
  /// that open the app, which reach [_onOpened] in the app.
  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
    await _plugin.initialize(
      settings: const AndroidInitializationSettings(
        '@drawable/ic_notification',
      ),
      onDidReceiveNotificationResponse: _onOpened,
      onDidReceiveBackgroundNotificationResponse: onNotificationResponse,
    );
  }

  static void _onOpened(NotificationResponse response) {
    final target = NotificationPayload.target(response.payload);
    if (target != null) {
      _opened.add(target);
    }
  }

  /// The group to open when a notification launched the app, then the ones
  /// opened while it runs.
  static Stream<NotificationTarget> _openedTargets() async* {
    final launch = await _plugin.getNotificationAppLaunchDetails();
    final target = launch != null && launch.didNotificationLaunchApp
        ? NotificationPayload.target(launch.notificationResponse?.payload)
        : null;
    if (target != null) {
      yield target;
    }
    yield* _opened.stream;
  }

  /// The Android implementations of the notification interfaces, and the
  /// planner as the listener of every schedule change.
  static List<Override> overrides() => [
    alarmSchedulerProvider.overrideWithValue(AndroidAlarmScheduler(_plugin)),
    notificationPresenterProvider.overrideWith(
      (ref) => AndroidNotificationPresenter(
        _plugin,
        ReviewTexts(
          _strings(
            ref.watch(
              interfaceSettingsProvider.select((settings) => settings.language),
            ),
          ),
          ref.watch(schedulingCalendarProvider),
        ),
        ref.watch(imageStoreProvider),
      ),
    ),
    plannedAlarmStoreProvider.overrideWithValue(SharedPreferencesAlarmStore()),
    scheduleChangeListenerProvider.overrideWith(
      (ref) => ref.watch(notificationPlannerProvider),
    ),
    notificationTargetsProvider.overrideWithValue(_openedTargets()),
  ];

  /// Texts in the language chosen in Settings, resolved like the screens.
  /// Background tasks have no widget tree to read it from.
  static AppLocalizations _strings(LanguageChoice language) =>
      lookupAppLocalizations(
        AppLocale.resolve(language, PlatformDispatcher.instance.locale),
      );
}
