import 'package:material_ui/material_ui.dart';

import '../../l10n/generated/app_localizations.dart';

/// Asks for a single line of text, such as a group name. Returns the trimmed
/// text, or `null` when cancelled or left empty.
Future<String?> showTextInputDialog(
  BuildContext context, {
  required String title,
  required String label,
  String initialText = '',
}) async {
  final text = await showDialog<String>(
    context: context,
    builder: (context) =>
        _TextInputDialog(title: title, label: label, initialText: initialText),
  );
  final trimmed = text?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  } else {
    return trimmed;
  }
}

/// Owns its text controller, so that the controller lives as long as the
/// field, closing animation included.
class _TextInputDialog extends StatefulWidget {
  const _TextInputDialog({
    required this.title,
    required this.label,
    required this.initialText,
  });

  final String title;
  final String label;
  final String initialText;

  @override
  State<_TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<_TextInputDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialText,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(labelText: widget.label),
        onSubmitted: (value) => Navigator.of(context).pop(value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.commonCancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(strings.commonOk),
        ),
      ],
    );
  }
}
