import 'package:flutter/material.dart';

import '../../app/theme/remanence_colors.dart';

/// Orange note warning about what a distillation launch changes or why it
/// is blocked.
class DistillationWarning extends StatelessWidget {
  const DistillationWarning(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = RemanenceColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.againBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 20,
            color: colors.againForeground,
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: colors.againForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
