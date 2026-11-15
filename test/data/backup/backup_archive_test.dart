import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alambic/data/backup/backup_archive.dart';
import 'package:alambic/data/backup/backup_contents.dart';
import 'package:alambic/data/backup/invalid_backup_exception.dart';
import 'package:alambic/data/backup/invalid_backup_kind.dart';

void main() {
  const archive = BackupArchive();
  final exportedAt = DateTime.utc(2026, 11, 15, 10);

  Uint8List zipOf(Map<String, List<int>> entries) {
    final zip = Archive();
    for (final MapEntry(:key, :value) in entries.entries) {
      zip.addFile(ArchiveFile.bytes(key, value));
    }
    return Uint8List.fromList(ZipEncoder().encode(zip));
  }

  Uint8List manifestZip(Map<String, Object?> manifest) =>
      zipOf({BackupArchive.manifestName: utf8.encode(jsonEncode(manifest))});

  Map<String, Object?> manifest({
    int formatVersion = 1,
    Object? tables = const <String, Object?>{},
  }) => {
    'format': 'alambic-backup',
    'formatVersion': formatVersion,
    'schemaVersion': 1,
    'tables': tables,
  };

  InvalidBackupKind kindOf(Uint8List bytes) {
    try {
      archive.decode(bytes);
    } on InvalidBackupException catch (error) {
      return error.kind;
    }
    fail('the file was accepted');
  }

  test('rows and images survive a round trip', () {
    final contents = BackupContents(
      schemaVersion: 1,
      tables: {
        'flashcards': [
          {'id': 1, 'front_text': 'Pérou', 'back_text': null, 'weight': 1.5},
        ],
        'card_groups': [],
      },
      images: {
        'a.jpg': Uint8List.fromList([1, 2, 3]),
      },
    );
    final decoded = archive.decode(
      archive.encode(contents, exportedAt: exportedAt),
    );
    expect(decoded.schemaVersion, 1);
    expect(decoded.tables, contents.tables);
    expect(decoded.images, contents.images);
  });

  test('a file that is not a zip is refused', () {
    expect(
      kindOf(Uint8List.fromList(utf8.encode('hello'))),
      InvalidBackupKind.notABackup,
    );
  });

  test('a zip without the Alambic document is refused', () {
    expect(
      kindOf(
        zipOf({
          'notes.txt': [1],
        }),
      ),
      InvalidBackupKind.notABackup,
    );
  });

  test('a zip of another application is refused', () {
    expect(
      kindOf(manifestZip({'format': 'anki', 'formatVersion': 1})),
      InvalidBackupKind.notABackup,
    );
  });

  test('a backup written by a newer format is refused', () {
    expect(
      kindOf(manifestZip(manifest(formatVersion: 2))),
      InvalidBackupKind.incompatibleVersion,
    );
  });

  test('a damaged document is refused', () {
    expect(
      kindOf(zipOf({BackupArchive.manifestName: utf8.encode('{"format"')})),
      InvalidBackupKind.corrupted,
    );
    expect(
      kindOf(manifestZip(manifest(tables: {'flashcards': 'oops'}))),
      InvalidBackupKind.corrupted,
    );
  });

  test('an image outside the images folder is refused', () {
    final bytes = zipOf({
      BackupArchive.manifestName: utf8.encode(jsonEncode(manifest())),
      'images/../../escape.jpg': [1],
    });
    expect(kindOf(bytes), InvalidBackupKind.corrupted);
  });
}
