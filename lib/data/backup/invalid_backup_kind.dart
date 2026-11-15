/// Why a file cannot be imported as a backup.
enum InvalidBackupKind {
  /// Not a zip file, or a zip file that Alambic did not write.
  notABackup,

  /// Written by a version of the app whose data this one cannot read.
  incompatibleVersion,

  /// A backup of Alambic whose content is damaged or incomplete.
  corrupted,
}
