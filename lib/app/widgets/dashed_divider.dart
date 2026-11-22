import 'package:material_ui/material_ui.dart';

import '../theme/alambic_colors.dart';

/// One pixel dashed rule in the border colour: what lies beyond the plain
/// timeline, or before it.
class DashedDivider extends StatelessWidget {
  const DashedDivider({super.key});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: CustomPaint(
      size: const Size.fromHeight(1),
      painter: _DashedPainter(AlambicColors.of(context).border),
    ),
  );
}

class _DashedPainter extends CustomPainter {
  const _DashedPainter(this.color);

  static const double _dash = 4;
  static const double _gap = 3;

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += _dash + _gap) {
      canvas.drawLine(Offset(x, 0.5), Offset(x + _dash, 0.5), paint);
    }
  }

  @override
  bool shouldRepaint(_DashedPainter oldDelegate) => oldDelegate.color != color;
}
