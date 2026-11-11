import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/remanence_app.dart';
import 'application/notifications/notification_providers.dart';
import 'data/data_providers.dart';
import 'data/database/remanence_database.dart';
import 'notifications/android/android_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidNotifications.initialize();
  final database = RemanenceDatabase.open();
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(database),
      ...AndroidNotifications.overrides(),
    ],
  );
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const RemanenceApp(),
    ),
  );
  await container.read(notificationPresenterProvider).requestPermission();
  // Scheduled again at each launch: alarms are lost when the app is
  // force-stopped, and the exact alarm permission may have changed.
  await container.read(notificationPlannerProvider).replan(force: true);
}
