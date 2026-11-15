import 'package:flutter/material.dart';

/// Asks to pick one of [options], each shown with its label, the current
/// one ticked. Returns `null` when the dialog is dismissed.
Future<T?> showChoiceDialog<T>(
  BuildContext context, {
  required String title,
  required Map<T, String> options,
  required T selected,
}) => showDialog<T>(
  context: context,
  builder: (context) => SimpleDialog(
    title: Text(title),
    children: [
      for (final MapEntry(key: value, value: label) in options.entries)
        ListTile(
          title: Text(label),
          trailing: value == selected
              ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
              : null,
          onTap: () => Navigator.of(context).pop(value),
        ),
    ],
  ),
);
