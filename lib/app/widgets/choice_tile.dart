import 'package:flutter/material.dart';

import '../theme/alambic_colors.dart';

/// One option of a list where a single option is active (preset picker,
/// group picker, day of a reminder). The active tile is outlined in accent
/// on an accent tint; the others are plain surfaces with a 1 px border.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.detail,
    super.key,
  });

  final String label;

  /// A second line under the label (summary of a preset, a date).
  final String? detail;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(
        color: isSelected ? colors.accentText : colors.border,
        width: isSelected ? 2 : 1,
      ),
    );
    return Semantics(
      selected: isSelected,
      button: true,
      child: Material(
        color: isSelected ? colors.accentTint : colors.surface,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? colors.accentText : colors.textPrimary,
                  ),
                ),
                if (detail != null)
                  Text(
                    detail!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? colors.accentText
                          : colors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
