import 'package:material_ui/material_ui.dart';

import '../theme/alambic_colors.dart';
import 'segment_option.dart';

/// Hollow track with equal segments; the selected one is a raised, outlined
/// pill with bold text, so the selection never rests on the fill alone. The
/// only control for a choice of 2 or 3 states.
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
    final colors = AlambicColors.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.well,
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
    AlambicColors colors,
  ) => Semantics(
    selected: isSelected,
    button: true,
    enabled: option.enabled,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: option.enabled ? () => onSelected(option.value) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 40,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? colors.surfaceRaised : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? colors.border : Colors.transparent,
          ),
        ),
        child: Text(
          option.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? colors.textPrimary
                : colors.textSecondary.withValues(
                    alpha: option.enabled ? 1 : 0.5,
                  ),
          ),
        ),
      ),
    ),
  );
}
