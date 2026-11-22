import 'package:material_ui/material_ui.dart';

import '../theme/alambic_colors.dart';

/// A short tag on a tinted background ("Default").
class BadgeLabel extends StatelessWidget {
  const BadgeLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.accentTint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colors.accentText,
        ),
      ),
    );
  }
}
