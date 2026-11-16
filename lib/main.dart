import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/alambic_app.dart';
import 'application/distillation/distillation_providers.dart';
import 'application/notifications/notification_providers.dart';
import 'application/preferences/interface_settings_providers.dart';
import 'data/data_providers.dart';
import 'data/database/alambic_database.dart';
import 'data/images/image_store.dart';
import 'data/preferences/shared_preferences_interface_settings_store.dart';
import 'notifications/android/android_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Drawn under the system bars, as Android 15 imposes; every screen keeps
  // its content clear of them (see `scrollPadding` and the SafeAreas).
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await AndroidNotifications.initialize();
  final database = AlambicDatabase.open();
  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(database),
      imageStoreProvider.overrideWithValue(await ImageStore.open()),
      // Read before the first frame, so that the app opens directly on the
      // right screen, in the right language and theme.
      ...await interfaceSettingsOverrides(
        SharedPreferencesInterfaceSettingsStore(),
      ),
      ...AndroidNotifications.overrides(),
    ],
  );
  runApp(
    UncontrolledProviderScope(container: container, child: const AlambicApp()),
  );
  // A day not processed yet by the distillations (the phone was off at the
  // start of the day) is processed now.
  await container.read(distillationServiceProvider).advance();
  // Scheduled again at each launch: alarms are lost when the app is
  // force-stopped, and the exact alarm permission may have changed.
  await container.read(notificationPlannerProvider).replan(force: true);
}
