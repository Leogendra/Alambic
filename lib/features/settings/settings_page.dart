import 'package:material_ui/material_ui.dart';

import '../../app/layout/scroll_padding.dart';

/// A page of one category of settings: an app bar with its title above a
/// scrolling list of panels, spaced the same way on every page.
class SettingsPage extends StatelessWidget {
  const SettingsPage({required this.title, required this.children, super.key});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: ListView(
      padding: scrollPadding(context, const EdgeInsets.fromLTRB(20, 8, 20, 32)),
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) const SizedBox(height: 14),
          children[index],
        ],
      ],
    ),
  );
}
