import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/notification_settings_repository.dart';
import 'package:alambic/domain/notifications/notification_guards.dart';
import 'package:alambic/features/settings/notification_guards_screen.dart';

import '../../support/fixed_clock.dart';
import '../../support/screen_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';
import '../../support/test_screen.dart';

void main() {
  late AlambicDatabase database;

  setUp(() async {
    database = openTestDatabase();
    await seedSampleData(SampleServices(database, FixedClock(sampleNow)));
  });

  tearDown(() => closeTestDatabase(database));

  testScreen('shows the cap against tomorrow, quiet hours and grouping', (
    tester,
  ) async {
    // The reverse of "Peru" is due tomorrow: a cap of one card shows it
    // sent, and lowering nothing else keeps the defaults on screen.
    await tester.runAsync(
      () =>
          NotificationSettingsRepository(database)
              .saveGuards(NotificationGuards.defaults.copyWith(dailyCap: 1)),
    );
    await pumpScreen(
      tester,
      const NotificationGuardsScreen(),
      overrides: screenOverrides(database, sampleNow),
    );
    await captureShot(
      tester,
      find.byType(NotificationGuardsScreen),
      'notification_guards',
    );
    await tester.runAsync(() async {
      await tester.tap(find.byTooltip(l10n.guardsIncrease).first);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    final guards = await tester.runAsync(
      () => NotificationSettingsRepository(database).loadGuards(),
    );
    expect(guards!.dailyCap, 2);
  });
}
