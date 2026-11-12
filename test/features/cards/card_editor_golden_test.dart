import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/data_providers.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/features/cards/card_editor_screen.dart';
import 'package:alambic/features/cards/image_picking.dart';

import '../../support/golden_harness.dart';
import '../../support/test_database.dart';
import '../../support/test_images.dart';

void main() {
  late AlambicDatabase database;

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

  testWidgets('a front image is picked, shown, then stored with the card', (
    tester,
  ) async {
    final images = openTestImageStore();
    await pumpGolden(
      tester,
      const CardEditorScreen(),
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
      'Quel pays a ce drapeau ?',
    );
    await tester.enterText(find.byType(TextField).last, 'Pérou');
    await precacheImageFile(tester, 'test/support/fixtures/flag.png');
    await tester.tap(find.text('Image').first);
    await tester.pumpAndSettle();
    expect(find.text('Image'), findsOneWidget, reason: 'the back one only');
    await expectLater(
      find.byType(CardEditorScreen),
      matchesGoldenFile('goldens/card_editor_image.png'),
    );
    await tester.runAsync(() async {
      await tester.tap(find.text('Créer'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    final card = (await tester.runAsync(
      () => CardRepository(database).getAll(),
    ))!.single.card;
    expect(card.frontText, 'Quel pays a ce drapeau ?');
    expect(File(images.pathOf(card.frontImagePath!)).existsSync(), isTrue);
  });
}

class _FakePicking implements ImagePicking {
  const _FakePicking(this.path);

  final String path;

  @override
  Future<String?> pick() async => path;
}
