import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/notifications/notification_action.dart';
import '../../application/notifications/notification_providers.dart';
import '../../data/data_providers.dart';
import '../../data/database/remanence_database.dart';
import 'android_notifications.dart';
import 'notification_payload.dart';

/// Runs in a background isolate when a wake-up planned by the app fires:
/// shows what is due, then plans the next wake-ups.
@pragma('vm:entry-point')
Future<void> onReviewAlarm(int alarmId) => _runInBackground(
  (container) => container.read(notificationDispatcherProvider).dispatchDue(),
);

/// Runs in a background isolate when a button of a review notification is
/// pressed, app open or not.
@pragma('vm:entry-point')
Future<void> onNotificationResponse(NotificationResponse response) async {
  final key = NotificationPayload.decode(response.payload);
  final action = NotificationAction.values
      .where((action) => action.name == response.actionId)
      .firstOrNull;
  if (key != null && action != null) {
    await _runInBackground(
      (container) =>
          container.read(notificationActionHandlerProvider).handle(key, action),
    );
  }
}

/// Opens the database and the services for one background task, then
/// releases them. The database connection is shared with the app when it
/// runs, so its screens follow the change.
Future<void> _runInBackground(
  Future<void> Function(ProviderContainer container) task,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  await AndroidNotifications.initialize();
  final database = RemanenceDatabase.open();
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(database),
      ...AndroidNotifications.overrides(),
    ],
  );
  try {
    await task(container);
  } finally {
    container.dispose();
    await database.close();
  }
}
