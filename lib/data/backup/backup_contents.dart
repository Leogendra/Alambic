import 'dart:typed_data';

/// What a backup holds: the rows of every table and the card images.
class BackupContents {
  const BackupContents({
    required this.schemaVersion,
    required this.tables,
    required this.images,
  });

  /// Version of the database schema the rows were read from.
  final int schemaVersion;

  /// Rows of each table, by table name, as stored by SQLite.
  final Map<String, List<Map<String, Object?>>> tables;

  /// Bytes of each image file, by file name.
  final Map<String, Uint8List> images;
}
