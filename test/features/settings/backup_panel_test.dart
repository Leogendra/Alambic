import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:alambic/application/backup/backup_providers.dart';
import 'package:alambic/data/backup/backup_archive.dart';
import 'package:alambic/data/backup/backup_contents.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/features/settings/backup_panel.dart';

import '../../support/fake_backup_files.dart';
import '../../support/golden_harness.dart';
import '../../support/sample_data.dart';
import '../../support/test_database.dart';
import '../../support/test_screen.dart';

void main() {
  late AlambicDatabase database;
  late FakeBackupFiles files;

  setUp(() {
    database = openTestDatabase();
    files = FakeBackupFiles();
  });

  tearDown(() => closeTestDatabase(database));

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

  testScreen('says when the file is not a backup of Alambic', (tester) async {
    files.picked = Uint8List.fromList([1, 2, 3]);
    await pumpPanel(tester);
    await tester.tap(find.text(l10n.backupImport));
    await tester.pumpAndSettle();
    expect(find.text('This file is not an Alambic backup.'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testScreen('asks for confirmation with what the file holds', (tester) async {
    files.picked = backupOf(1, 2);
    await pumpPanel(tester);
    await tester.tap(find.text(l10n.backupImport));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.textContaining('1 card in 2 groups'), findsOneWidget);
    await tester.tap(find.text(l10n.commonCancel));
    await tester.pumpAndSettle();
    expect(find.text('Data imported'), findsNothing);
  });
}
