import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/alambic_app.dart';
import 'application/distillation/distillation_providers.dart';
import 'application/notifications/notification_providers.dart';
import 'data/data_providers.dart';
import 'data/database/alambic_database.dart';
import 'notifications/android/android_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidNotifications.initialize();
  final database = AlambicDatabase.open();
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(database),
      ...AndroidNotifications.overrides(),
    ],
  );
  runApp(
    UncontrolledProviderScope(container: container, child: const AlambicApp()),
  );
  await container.read(notificationPresenterProvider).requestPermission();
  // A day not processed yet by the distillations (the phone was off at the
  // start of the day) is processed now.
  await container.read(distillationServiceProvider).advance();
  // Scheduled again at each launch: alarms are lost when the app is
  // force-stopped, and the exact alarm permission may have changed.
  await container.read(notificationPlannerProvider).replan(force: true);
}
