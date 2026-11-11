import 'package:flutter/material.dart';

import '../theme/remanence_colors.dart';
import 'segment_option.dart';

/// Grey track with equal segments; the selected one is a white pill.
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<SegmentOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = RemanenceColors.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.segmentBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(child: _segment(option, option.value == selected, colors)),
        ],
      ),
    );
  }

  Widget _segment(
    SegmentOption<T> option,
    bool isSelected,
    RemanenceColors colors,
  ) => Semantics(
    selected: isSelected,
    button: true,
    child: GestureDetector(
      onTap: () => onSelected(option.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 40,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? colors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? const [BoxShadow(color: Color(0x1F0A0A0A), blurRadius: 3)]
              : null,
        ),
        child: Text(
          option.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected ? colors.textPrimary : colors.textSecondary,
          ),
        ),
      ),
    ),
  );
}
