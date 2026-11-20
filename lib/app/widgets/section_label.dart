import 'package:material_ui/material_ui.dart';

import '../theme/alambic_colors.dart';

/// Small uppercase title above a panel.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
        color: AlambicColors.of(context).textSecondary,
      ),
    ),
  );
}
