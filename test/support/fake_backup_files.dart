import 'dart:typed_data';

import 'package:alambic/data/backup/backup_files.dart';

/// A backup "drive" in memory: what the user saves is what they pick next.
class FakeBackupFiles implements BackupFiles {
  FakeBackupFiles({this.picked});

  String? savedName;
  Uint8List? saved;

  /// What the next [pick] returns; `null` simulates a cancelled dialog.
  Uint8List? picked;

  /// Makes [save] behave as if the user cancelled.
  bool cancelSave = false;

  @override
  Future<bool> save(String fileName, Uint8List bytes) async {
    if (cancelSave) {
      return false;
    }
    savedName = fileName;
    saved = bytes;
    return true;
  }

  @override
  Future<Uint8List?> pick() async => picked;
}
