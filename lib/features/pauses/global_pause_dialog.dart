import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/distillation/distillation_providers.dart';
import '../../l10n/generated/app_localizations.dart';

/// Starts the global pause once the user confirms it, from Home or Settings.
Future<void> confirmGlobalPause(BuildContext context, WidgetRef ref) async {
  final strings = AppLocalizations.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(strings.pauseAllConfirmTitle),
      content: Text(strings.pauseAllConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(strings.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(strings.pauseAllConfirm),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await ref.read(distillationServiceProvider).pauseAll();
  }
}
