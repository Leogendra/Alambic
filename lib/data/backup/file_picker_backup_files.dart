import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import 'backup_files.dart';

/// The system file dialogs, through the file_picker plugin.
class FilePickerBackupFiles implements BackupFiles {
  const FilePickerBackupFiles();

  @override
  Future<bool> save(String fileName, Uint8List bytes) async {
    final saved = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/zip',
    );
    return saved != null;
  }

  @override
  Future<Uint8List?> pick() async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['zip'],
    );
    return file?.readAsBytes();
  }
}
