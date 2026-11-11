import 'dart:ui';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/misc.dart';

import '../../application/clock.dart';
import '../../application/notifications/notification_providers.dart';
import '../../application/scheduling/scheduling_providers.dart';
import '../../l10n/generated/app_localizations.dart';
import '../review_texts.dart';
import '../shared_preferences_alarm_store.dart';
import 'android_alarm_scheduler.dart';
import 'android_notification_presenter.dart';
import 'background_entry_points.dart';

/// Wiring of the Android notification layer, shared by the app and by the
/// background tasks, which each run in their own isolate.
abstract final class AndroidNotifications {
  static final AndroidFlutterLocalNotificationsPlugin _plugin =
      AndroidFlutterLocalNotificationsPlugin();

  /// Initializes the plugins in the current isolate. Buttons pressed on a
  /// notification are always handled by [onNotificationResponse] in a
  /// background isolate, whether the app is open or not.
  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
    await _plugin.initialize(
      settings: const AndroidInitializationSettings('@mipmap/ic_launcher'),
      onDidReceiveBackgroundNotificationResponse: onNotificationResponse,
    );
  }

  /// The Android implementations of the notification interfaces, and the
  /// planner as the listener of every schedule change.
  static List<Override> overrides() => [
    alarmSchedulerProvider.overrideWithValue(AndroidAlarmScheduler(_plugin)),
    notificationPresenterProvider.overrideWith(
      (ref) => AndroidNotificationPresenter(
        _plugin,
        ReviewTexts(_strings(), ref.watch(schedulingCalendarProvider)),
      ),
    ),
    plannedAlarmStoreProvider.overrideWithValue(SharedPreferencesAlarmStore()),
    scheduleChangeListenerProvider.overrideWith(
      (ref) => ref.watch(notificationPlannerProvider),
    ),
  ];

  /// Texts in the language of the phone when the app has it, French
  /// otherwise. Background tasks have no widget tree to read it from.
  static AppLocalizations _strings() {
    final locale = PlatformDispatcher.instance.locale;
    final supported = AppLocalizations.supportedLocales.any(
      (candidate) => candidate.languageCode == locale.languageCode,
    );
    return lookupAppLocalizations(
      supported ? Locale(locale.languageCode) : const Locale('fr'),
    );
  }
}
