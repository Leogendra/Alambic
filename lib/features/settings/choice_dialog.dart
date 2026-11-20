import 'package:material_ui/material_ui.dart';

import '../../app/widgets/choice_tile.dart';

/// Asks to pick one of [options], each shown with its label, the current
/// one selected. Returns `null` when the dialog is dismissed.
Future<T?> showChoiceDialog<T>(
  BuildContext context, {
  required String title,
  required Map<T, String> options,
  required T selected,
}) => showDialog<T>(
  context: context,
  builder: (context) => SimpleDialog(
    title: Text(title),
    contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
    children: [
      for (final MapEntry(key: value, value: label) in options.entries)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ChoiceTile(
            label: label,
            isSelected: value == selected,
            onTap: () => Navigator.of(context).pop(value),
          ),
        ),
    ],
  ),
);
