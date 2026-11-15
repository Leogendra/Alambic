import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/backup/backup_providers.dart';
import 'package:alambic/data/backup/backup_archive.dart';
import 'package:alambic/data/backup/backup_contents.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/features/settings/backup_panel.dart';

import '../../support/fake_backup_files.dart';
import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';

void main() {
  late AlambicDatabase database;
  late FakeBackupFiles files;

  setUp(() {
    database = openTestDatabase();
    files = FakeBackupFiles();
  });

  tearDown(() => database.close());

  Future<void> pumpPanel(WidgetTester tester) => pumpGolden(
    tester,
    const Scaffold(body: SafeArea(child: BackupPanel())),
    overrides: [
      ...screenOverrides(database, sampleNow),
      backupFilesProvider.overrideWithValue(files),
    ],
  );

  Uint8List backupOf(int cards, int groups) => const BackupArchive().encode(
    BackupContents(
      schemaVersion: database.schemaVersion,
      tables: {
        for (final table in database.allTables) table.actualTableName: [],
        'flashcards': List.generate(cards, (index) => {'id': index}),
        'card_groups': List.generate(groups, (index) => {'id': index}),
      },
      images: const {},
    ),
    exportedAt: sampleNow,
  );

  testWidgets('says when the file is not a backup of Alambic', (tester) async {
    files.picked = Uint8List.fromList([1, 2, 3]);
    await pumpPanel(tester);
    await tester.tap(find.text('Importer des données'));
    await tester.pumpAndSettle();
    expect(
      find.text("Ce fichier n'est pas une sauvegarde d'Alambic."),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('asks for confirmation with what the file holds', (tester) async {
    files.picked = backupOf(1, 2);
    await pumpPanel(tester);
    await tester.tap(find.text('Importer des données'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('1 carte dans 2 groupes'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(find.text('Données importées'), findsNothing);
  });
}
