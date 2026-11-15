import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

import 'backup_contents.dart';
import 'invalid_backup_exception.dart';
import 'invalid_backup_kind.dart';

/// Reads and writes the zip file of a backup: one JSON document with the rows
/// of the tables, and the card images in an `images/` folder.
///
/// Every failure to read is an [InvalidBackupException], so that the caller
/// refuses a bad file before replacing anything.
class BackupArchive {
  const BackupArchive();

  static const String manifestName = 'alambic.json';
  static const String imagesFolder = 'images/';
  static const String formatName = 'alambic-backup';

  /// Layout of the zip file. Raised when the file structure changes, not when
  /// the database schema does.
  static const int formatVersion = 1;

  Uint8List encode(BackupContents contents, {required DateTime exportedAt}) {
    final manifest = jsonEncode({
      'format': formatName,
      'formatVersion': formatVersion,
      'schemaVersion': contents.schemaVersion,
      'exportedAt': exportedAt.toUtc().toIso8601String(),
      'tables': contents.tables,
    });
    final archive = Archive()
      ..addFile(ArchiveFile.bytes(manifestName, utf8.encode(manifest)));
    for (final MapEntry(key: name, value: bytes) in contents.images.entries) {
      archive.addFile(ArchiveFile.bytes('$imagesFolder$name', bytes));
    }
    return Uint8List.fromList(ZipEncoder().encode(archive));
  }

  BackupContents decode(Uint8List bytes) {
    final archive = _openArchive(bytes);
    final manifest = _readManifest(archive);
    return BackupContents(
      schemaVersion: _readSchemaVersion(manifest),
      tables: _readTables(manifest),
      images: _readImages(archive),
    );
  }

  Archive _openArchive(Uint8List bytes) {
    try {
      return ZipDecoder().decodeBytes(bytes);
    } on Object {
      throw const InvalidBackupException(
        InvalidBackupKind.notABackup,
        'not a zip file',
      );
    }
  }

  Map<String, Object?> _readManifest(Archive archive) {
    final file = archive.findFile(manifestName);
    if (file == null) {
      throw const InvalidBackupException(
        InvalidBackupKind.notABackup,
        'no $manifestName in the zip file',
      );
    }
    final Object? manifest;
    try {
      manifest = jsonDecode(utf8.decode(file.readBytes()!));
    } on FormatException {
      throw const InvalidBackupException(
        InvalidBackupKind.corrupted,
        '$manifestName is not valid JSON',
      );
    }
    if (manifest is! Map<String, Object?> || manifest['format'] != formatName) {
      throw const InvalidBackupException(
        InvalidBackupKind.notABackup,
        '$manifestName is not an Alambic backup',
      );
    }
    final version = manifest['formatVersion'];
    if (version is! int || version > formatVersion) {
      throw InvalidBackupException(
        InvalidBackupKind.incompatibleVersion,
        'backup format $version, this app reads up to $formatVersion',
      );
    }
    return manifest;
  }

  int _readSchemaVersion(Map<String, Object?> manifest) {
    final version = manifest['schemaVersion'];
    if (version is! int) {
      throw const InvalidBackupException(
        InvalidBackupKind.corrupted,
        'no schema version',
      );
    }
    return version;
  }

  Map<String, List<Map<String, Object?>>> _readTables(
    Map<String, Object?> manifest,
  ) {
    final tables = manifest['tables'];
    if (tables is! Map<String, Object?>) {
      throw const InvalidBackupException(
        InvalidBackupKind.corrupted,
        'no tables',
      );
    }
    return {
      for (final MapEntry(key: name, value: rows) in tables.entries)
        name: _readRows(name, rows),
    };
  }

  List<Map<String, Object?>> _readRows(String table, Object? rows) {
    if (rows is! List<Object?> ||
        rows.any((row) => row is! Map<String, Object?>)) {
      throw InvalidBackupException(
        InvalidBackupKind.corrupted,
        'rows of $table are malformed',
      );
    }
    return rows.cast<Map<String, Object?>>();
  }

  Map<String, Uint8List> _readImages(Archive archive) => {
    for (final file in archive.files)
      if (file.isFile && file.name.startsWith(imagesFolder))
        _imageName(file.name): file.readBytes()!,
  };

  /// An image sits directly in the folder: a name with a path would let a
  /// crafted file write outside of the image store.
  String _imageName(String entryName) {
    final name = entryName.substring(imagesFolder.length);
    if (name.isEmpty || name.contains('/') || name.contains(r'\')) {
      throw InvalidBackupException(
        InvalidBackupKind.corrupted,
        'unexpected image path $entryName',
      );
    }
    return name;
  }
}
