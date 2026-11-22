import 'package:material_ui/material_ui.dart';

import '../theme/alambic_colors.dart';

/// A step of a sequence ("1 wk"), highlighted when it is the current step.
class IntervalChip extends StatelessWidget {
  const IntervalChip({
    required this.label,
    this.highlighted = false,
    super.key,
  });

  final String label;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlighted ? colors.accent : colors.accentTint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: highlighted ? colors.onAccent : colors.accentText,
        ),
      ),
    );
  }
}
