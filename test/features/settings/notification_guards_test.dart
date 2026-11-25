import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/notification_settings_repository.dart';
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

  testScreen('shows the smoothing of the due dates', (tester) async {
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
    await expectNoOverflow(tester);
    expect(find.text(l10n.guardsSmoothDueDates), findsOneWidget);
    await tester.runAsync(() async {
      await tester.tap(find.byType(Switch).first);
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    final guards = await tester.runAsync(
      () => NotificationSettingsRepository(database).loadGuards(),
    );
    expect(guards!.smoothDueDates, isTrue);
  });
}
