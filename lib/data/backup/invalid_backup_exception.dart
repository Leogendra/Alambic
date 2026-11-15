import 'invalid_backup_kind.dart';

/// A file refused as a backup. Thrown before any current data is touched.
class InvalidBackupException implements Exception {
  const InvalidBackupException(this.kind, this.detail);

  final InvalidBackupKind kind;
  final String detail;

  @override
  String toString() => 'InvalidBackupException(${kind.name}): $detail';
}
