import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remanence/data/data_providers.dart';
import 'package:remanence/data/database/remanence_database.dart';
import 'package:remanence/features/cards/card_editor_screen.dart';

import '../../support/golden_harness.dart';
import '../../support/test_database.dart';

void main() {
  late RemanenceDatabase database;

  setUp(() => database = openTestDatabase());
  tearDown(() => database.close());

  testWidgets('new card with both faces and the reverse direction', (
    tester,
  ) async {
    await pumpGolden(
      tester,
      const CardEditorScreen(),
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    await tester.enterText(find.byType(TextField).first, 'Mongolie');
    await tester.enterText(find.byType(TextField).last, 'Oulan-Bator');
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(CardEditorScreen),
      matchesGoldenFile('goldens/card_editor_new.png'),
    );
  });
}
