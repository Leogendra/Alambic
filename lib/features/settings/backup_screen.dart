import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/widgets/panel_row.dart';
import '../../app/widgets/surface_panel.dart';
import '../../application/backup/backup_preview.dart';
import '../../application/backup/backup_providers.dart';
import '../../data/backup/invalid_backup_exception.dart';
import '../../data/backup/invalid_backup_kind.dart';
import '../../l10n/generated/app_localizations.dart';
import 'settings_page.dart';

/// Export and import of all the data as a zip file.
class BackupScreen extends ConsumerWidget {
  const BackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    return SettingsPage(
      title: strings.settingsBackup,
      children: [
        SurfacePanel(
          children: [
            PanelRow(
              title: strings.backupExport,
              subtitle: strings.backupExportHint,
              trailing: const Icon(Icons.upload_file_outlined),
              onTap: () => _export(context, ref),
            ),
            PanelRow(
              title: strings.backupImport,
              subtitle: strings.backupImportHint,
              trailing: const Icon(Icons.download_outlined),
              onTap: () => _import(context, ref),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final strings = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      if (await ref.read(backupServiceProvider).export()) {
        messenger.showSnackBar(
          SnackBar(content: Text(strings.backupExportDone)),
        );
      }
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(strings.backupFailed)));
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final strings = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(backupServiceProvider);
    try {
      final preview = await service.pickBackup();
      if (preview == null || !context.mounted) {
        return;
      }
      if (await _confirm(context, preview) ?? false) {
        await service.restore(preview);
        messenger.showSnackBar(
          SnackBar(content: Text(strings.backupImportDone)),
        );
      }
    } on InvalidBackupException catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(_message(strings, error.kind))),
      );
    } on Exception {
      messenger.showSnackBar(SnackBar(content: Text(strings.backupFailed)));
    }
  }

  String _message(AppLocalizations strings, InvalidBackupKind kind) =>
      switch (kind) {
        InvalidBackupKind.notABackup => strings.backupNotABackup,
        InvalidBackupKind.incompatibleVersion =>
          strings.backupIncompatibleVersion,
        InvalidBackupKind.corrupted => strings.backupCorrupted,
      };

  Future<bool?> _confirm(BuildContext context, BackupPreview preview) {
    final strings = AppLocalizations.of(context);
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.backupImportConfirmTitle),
        content: Text(
          strings.backupImportConfirmBody(
            preview.cardCount,
            preview.groupCount,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.backupImportConfirm),
          ),
        ],
      ),
    );
  }
}
