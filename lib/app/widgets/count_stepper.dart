import 'package:material_ui/material_ui.dart';

import '../theme/alambic_colors.dart';

/// "− value +" control bounded by [min] and [max].
class CountStepper extends StatelessWidget {
  const CountStepper({
    required this.value,
    required this.label,
    required this.onChanged,
    required this.decreaseTooltip,
    required this.increaseTooltip,
    this.min = 1,
    this.max = 99,
    super.key,
  });

  final int value;

  /// How [value] is shown, such as "3 d".
  final String label;
  final ValueChanged<int> onChanged;
  final String decreaseTooltip;
  final String increaseTooltip;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: decreaseTooltip,
            icon: const Icon(Icons.remove, size: 20),
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          SizedBox(
            width: 44,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
          ),
          IconButton(
            tooltip: increaseTooltip,
            icon: const Icon(Icons.add, size: 20),
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}
