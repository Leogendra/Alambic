import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/data/data_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/data/repositories/group_repository.dart';
import 'package:alambic/features/cards/card_editor_screen.dart';
import 'package:alambic/features/cards/image_picking.dart';

import '../../support/screen_harness.dart';
import '../../support/test_database.dart';
import '../../support/test_images.dart';
import '../../support/test_screen.dart';

void main() {
  late AlambicDatabase database;
  late int groupId;

  setUp(() async {
    database = openTestDatabase();
    groupId = await GroupRepository(database)
        .create('Capitals', DateTime(2026, 11, 10));
  });
  tearDown(() => closeTestDatabase(database));

  testScreen('new card with both faces, in a group', (tester) async {
    await pumpScreen(
      tester,
      CardEditorScreen(initialGroupId: groupId),
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    await tester.enterText(find.byType(TextField).first, 'Mongolia');
    await tester.enterText(find.byType(TextField).last, 'Ulaanbaatar');
    await tester.pumpAndSettle();
    expect(find.text('Capitals'), findsOneWidget);
    await captureShot(tester, find.byType(CardEditorScreen), 'card_editor_new');
    await expectNoOverflow(tester);
  });

  testScreen('a front image is picked, shown, then stored with the card', (
    tester,
  ) async {
    final images = openTestImageStore();
    await pumpScreen(
      tester,
      CardEditorScreen(initialGroupId: groupId),
      overrides: [
        databaseProvider.overrideWithValue(database),
        imageStoreProvider.overrideWithValue(images),
        imagePickingProvider.overrideWithValue(
          const _FakePicking('test/support/fixtures/flag.png'),
        ),
      ],
    );
    await tester.enterText(
      find.byType(TextField).first,
      'Which country has this flag?',
    );
    await tester.enterText(find.byType(TextField).last, 'Peru');
    await precacheImageFile(tester, 'test/support/fixtures/flag.png');
    await tester.tap(find.text('Image').first);
    await tester.pumpAndSettle();
    expect(find.text('Image'), findsOneWidget, reason: 'the back one only');
    await captureShot(
      tester,
      find.byType(CardEditorScreen),
      'card_editor_image',
    );
    await expectNoOverflow(tester);
    await tester.runAsync(() async {
      await tester.tap(find.text(l10n.cardEditorCreate));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    final card = (await tester.runAsync(
      () => CardRepository(database).getAll(),
    ))!.single;
    expect(card.frontText, 'Which country has this flag?');
    expect(File(images.pathOf(card.frontImagePath!)).existsSync(), isTrue);
  });
}

class _FakePicking implements ImagePicking {
  const _FakePicking(this.path);

  final String path;

  @override
  Future<String?> pick() async => path;
}
