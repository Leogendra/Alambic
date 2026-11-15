import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/backup/backup_archive.dart';
import '../../data/backup/backup_files.dart';
import '../../data/backup/database_snapshot.dart';
import '../../data/backup/file_picker_backup_files.dart';
import '../../data/data_providers.dart';
import '../clock.dart';
import '../scheduling/scheduling_providers.dart';
import 'backup_service.dart';

/// The file dialogs of the platform; replaced in tests.
final backupFilesProvider = Provider<BackupFiles>(
  (ref) => const FilePickerBackupFiles(),
);

final backupServiceProvider = Provider(
  (ref) => BackupService(
    snapshot: DatabaseSnapshot(ref.watch(databaseProvider)),
    images: ref.watch(imageStoreProvider),
    archive: const BackupArchive(),
    files: ref.watch(backupFilesProvider),
    clock: ref.watch(clockProvider),
    scheduleChangeListener: ref.watch(scheduleChangeListenerProvider),
  ),
);
