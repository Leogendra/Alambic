import 'package:material_ui/material_ui.dart';

import '../theme/alambic_colors.dart';

/// A value in large figures, with what it counts under it: "12" over "cards
/// within the month". A value too wide for its column shrinks to fit.
class BigFigure extends StatelessWidget {
  const BigFigure({
    required this.value,
    required this.caption,
    required this.color,
    this.size = 40,
    super.key,
  });

  final String value;
  final String caption;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 6,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
                height: 1,
                color: color,
              ),
            ),
          ),
          Text(
            caption,
            style: TextStyle(
              fontSize: 13,
              color: AlambicColors.of(context).textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
