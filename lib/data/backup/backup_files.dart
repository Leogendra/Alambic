import 'dart:typed_data';

/// Where the user keeps a backup: a file they save, and a file they pick.
/// The picker of the platform is behind this interface so that the backup
/// logic is tested without it.
abstract interface class BackupFiles {
  /// Lets the user choose where to save [bytes] as [fileName]. Returns
  /// `false` when they cancel.
  Future<bool> save(String fileName, Uint8List bytes);

  /// Lets the user pick a backup file and returns its content, or `null`
  /// when they cancel.
  Future<Uint8List?> pick();
}
