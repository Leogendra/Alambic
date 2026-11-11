import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Asks for a single line of text, such as a group name. Returns the trimmed
/// text, or `null` when cancelled or left empty.
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  required String label,
  String initialText = '',
}) async {
  final controller = TextEditingController(text: initialText);
  final strings = AppLocalizations.of(context);
  final text = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: label),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: Text(strings.commonOk),
        ),
      ],
    ),
  );
  controller.dispose();
  final trimmed = text?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  } else {
    return trimmed;
  }
}
