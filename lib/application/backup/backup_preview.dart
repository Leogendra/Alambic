import '../../data/backup/backup_contents.dart';

/// A backup file read and checked, ready to replace the current data once
/// the user confirms.
class BackupPreview {
  const BackupPreview(this.contents);

  final BackupContents contents;

  int get cardCount => contents.tables['flashcards']!.length;

  int get groupCount => contents.tables['card_groups']!.length;
}
