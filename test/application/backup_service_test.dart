import 'dart:typed_data';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/application/backup/backup_service.dart';
import 'package:alambic/application/cards/card_draft.dart';
import 'package:alambic/application/cards/draft_image.dart';
import 'package:alambic/data/backup/backup_archive.dart';
import 'package:alambic/data/backup/database_snapshot.dart';
import 'package:alambic/data/backup/invalid_backup_exception.dart';
import 'package:alambic/data/backup/invalid_backup_kind.dart';
import 'package:alambic/data/database/alambic_database.dart';
import 'package:alambic/data/images/image_store.dart';
import 'package:alambic/data/repositories/card_repository.dart';
import 'package:alambic/domain/cards/direction_sense.dart';
import 'package:alambic/domain/reviews/review_outcome.dart';
import 'package:alambic/domain/reviews/review_source.dart';

import '../support/fake_backup_files.dart';
import '../support/fixed_clock.dart';
import '../support/recording_schedule_listener.dart';
import '../support/sample_data.dart';
import '../support/test_database.dart';
import '../support/test_images.dart';

/// A device: its database, its images and the services over them.
class Device {
  Device(FakeBackupFiles files)
    : database = openTestDatabase(),
      images = openTestImageStore(),
      listener = RecordingScheduleListener() {
    services = SampleServices(database, FixedClock(sampleNow), images: images);
    backup = BackupService(
      snapshot: DatabaseSnapshot(database),
      images: images,
      archive: const BackupArchive(),
      files: files,
      clock: () => sampleNow,
      scheduleChangeListener: listener,
    );
  }

  final AlambicDatabase database;
  final ImageStore images;
  final RecordingScheduleListener listener;
  late final SampleServices services;
  late final BackupService backup;

  Future<Map<String, List<Map<String, Object?>>>> tables() =>
      DatabaseSnapshot(database).read();
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late FakeBackupFiles drive;
  late Device source;
  late Device target;

  setUp(() {
    drive = FakeBackupFiles();
    source = Device(drive);
    target = Device(drive);
  });

  tearDown(() async {
    await source.database.close();
    await target.database.close();
  });

  Future<void> fillSource() async {
    final capitals = await seedSampleData(source.services);
    await source.services.cards.create(
      CardDraft(
        frontText: '',
        backText: 'Pérou',
        frontImage: const PickedImage('test/support/fixtures/flag.png'),
        groupId: capitals,
        presetId: null,
        alsoReverse: false,
      ),
    );
    final cards = await CardRepository(source.database).getAll();
    final direction = cards.first.direction(DirectionSense.frontToBack)!;
    await source.services.reviews.answer(
      direction.id,
      ReviewOutcome.correct,
      source: ReviewSource.session,
    );
  }

  Future<void> importOnTarget() async {
    drive.picked = drive.saved;
    await target.backup.restore((await target.backup.pickBackup())!);
  }

  test('the file is named after the day of the export', () {
    expect(
      BackupService.fileName(DateTime(2026, 11, 5)),
      'alambic-2026-11-05.zip',
    );
  });

  test(
    'exporting then importing on an empty app restores everything',
    () async {
      await fillSource();
      await source.backup.export();

      await importOnTarget();

      expect(await target.tables(), await source.tables());
      expect(await target.images.readAll(), await source.images.readAll());
      expect(await target.images.readAll(), isNotEmpty);
    },
  );

  test('the preview counts the cards and the groups of the file', () async {
    await fillSource();
    await source.backup.export();
    drive.picked = drive.saved;

    final preview = (await target.backup.pickBackup())!;

    expect(preview.cardCount, 8);
    expect(preview.groupCount, 2);
  });

  test('importing replaces what the app holds, images included', () async {
    await fillSource();
    await source.backup.export();
    await target.services.groups.create('To delete');
    await target.images.replaceAll({
      'old.jpg': Uint8List.fromList([9]),
    });

    await importOnTarget();

    expect((await target.images.readAll()).keys, isNot(contains('old.jpg')));
    final groups = (await target.tables())['card_groups']!;
    expect(groups.map((row) => row['name']), ['Capitales', 'Espagnol']);
  });

  test('importing plans the notifications again', () async {
    await fillSource();
    await source.backup.export();

    await importOnTarget();

    expect(target.listener.changeCount, 1);
  });

  test('a cancelled dialog changes nothing', () async {
    drive.picked = null;
    expect(await target.backup.pickBackup(), isNull);
    drive.cancelSave = true;
    expect(await target.backup.export(), isFalse);
  });

  test('a refused file leaves the current data as it was', () async {
    await target.services.groups.create('Intact');
    final before = await target.tables();
    drive.picked = Uint8List.fromList([1, 2, 3]);

    await expectLater(
      target.backup.pickBackup(),
      throwsA(
        isA<InvalidBackupException>().having(
          (error) => error.kind,
          'kind',
          InvalidBackupKind.notABackup,
        ),
      ),
    );
    expect(await target.tables(), before);
  });

  test('a backup of another schema version is refused', () async {
    await source.backup.export();
    final contents = const BackupArchive().decode(drive.saved!);

    expect(
      () =>
          DatabaseSnapshot(target.database)
              .validate(contents.schemaVersion + 1, contents.tables),
      throwsA(isA<InvalidBackupException>()),
    );
  });

  test('a backup with an unknown column is refused', () async {
    await source.backup.export();
    final contents = const BackupArchive().decode(drive.saved!);
    contents.tables['presets']!.first['colour'] = 'blue';

    expect(
      () =>
          DatabaseSnapshot(target.database)
              .validate(contents.schemaVersion, contents.tables),
      throwsA(isA<InvalidBackupException>()),
    );
  });

  test('an insertion that fails keeps the current data', () async {
    await target.services.groups.create('Intact');
    final before = await target.tables();
    final broken = await source.tables();
    broken['flashcards']!.add({'id': 1, 'created_at': 0, 'suspended': 0});
    broken['flashcards']!.add({'id': 1, 'created_at': 0, 'suspended': 0});

    await expectLater(
      DatabaseSnapshot(target.database).replaceAll(broken),
      throwsA(anything),
    );
    expect(await target.tables(), before);
  });

  test('every table of the database is exported', () {
    expect(
      DatabaseSnapshot.insertionOrder.toSet(),
      source.database.allTables.map((table) => table.actualTableName).toSet(),
    );
  });
}
