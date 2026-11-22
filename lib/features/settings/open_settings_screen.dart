import 'package:material_ui/material_ui.dart';

/// Opens [screen] above the current one: a category of settings, or one
/// setting that has a screen of its own.
Future<void> openSettingsScreen(BuildContext context, Widget screen) =>
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (context) => screen));
