import '../../data/backup/backup_archive.dart';
import '../../data/backup/backup_contents.dart';
import '../../data/backup/backup_files.dart';
import '../../data/backup/database_snapshot.dart';
import '../../data/images/image_store.dart';
import '../clock.dart';
import '../scheduling/schedule_change_listener.dart';
import 'backup_preview.dart';

/// Exports all the data to a zip file and replaces it from one. There is no
/// automatic backup: the user keeps the file wherever they want.
///
/// Importing is done in two steps so that the user confirms knowing what the
/// file holds: [pickBackup] reads and checks it, [restore] replaces the data.
class BackupService {
  const BackupService({
    required this._snapshot,
    required this._images,
    required this._archive,
    required this._files,
    required this._clock,
    required this._scheduleChangeListener,
  });

  final DatabaseSnapshot _snapshot;
  final ImageStore _images;
  final BackupArchive _archive;
  final BackupFiles _files;
  final Clock _clock;
  final ScheduleChangeListener _scheduleChangeListener;

  /// Offers the user to save the backup. Returns `false` when they cancel.
  Future<bool> export() async {
    final now = _clock();
    final contents = BackupContents(
      schemaVersion: _snapshot.schemaVersion,
      tables: await _snapshot.read(),
      images: await _images.readAll(),
    );
    return _files.save(
      fileName(now),
      _archive.encode(contents, exportedAt: now),
    );
  }

  /// `alambic-2026-11-15.zip`.
  static String fileName(DateTime day) {
    String two(int value) => value.toString().padLeft(2, '0');
    return 'alambic-${day.year}-${two(day.month)}-${two(day.day)}.zip';
  }

  /// Asks the user for a backup file and checks it. Returns `null` when they
  /// cancel.
  ///
  /// Throws an `InvalidBackupException` for a file that cannot be imported.
  Future<BackupPreview?> pickBackup() async {
    final bytes = await _files.pick();
    if (bytes == null) {
      return null;
    }
    final contents = _archive.decode(bytes);
    _snapshot.validate(contents.schemaVersion, contents.tables);
    return BackupPreview(contents);
  }

  /// Replaces all the current data, images included, by the backup. The
  /// database is replaced first and in one transaction, so that a failure
  /// leaves the current data untouched.
  Future<void> restore(BackupPreview preview) async {
    await _snapshot.replaceAll(preview.contents.tables);
    await _images.replaceAll(preview.contents.images);
    await _scheduleChangeListener.onSchedulesChanged();
  }
}
