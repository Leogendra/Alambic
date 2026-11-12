import 'package:flutter/material.dart';

import '../../app/theme/alambic_colors.dart';

/// A count with its label, such as "5 Dues", in the header of a group.
class GroupStatTile extends StatelessWidget {
  const GroupStatTile({required this.value, required this.label, super.key});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
