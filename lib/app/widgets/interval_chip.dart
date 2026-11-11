import 'package:flutter/material.dart';

import '../theme/remanence_colors.dart';

/// A step of a sequence ("1 sem"), highlighted when it is the current step.
class IntervalChip extends StatelessWidget {
  const IntervalChip({
    required this.label,
    this.highlighted = false,
    this.onDeleted,
    this.deleteTooltip,
    super.key,
  });

  final String label;
  final bool highlighted;
  final VoidCallback? onDeleted;
  final String? deleteTooltip;

  @override
  Widget build(BuildContext context) {
    final colors = RemanenceColors.of(context);
    return Container(
      padding: EdgeInsets.fromLTRB(10, 6, onDeleted == null ? 10 : 4, 6),
      decoration: BoxDecoration(
        color: highlighted ? colors.accent : colors.accentTint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: highlighted ? Colors.white : colors.accentText,
            ),
          ),
          if (onDeleted != null)
            Tooltip(
              message: deleteTooltip ?? '',
              child: InkWell(
                onTap: onDeleted,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(Icons.close, size: 16, color: colors.accentText),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
