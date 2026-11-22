import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';

/// The steps of a sequence as a vertical timeline, the nearest step on top,
/// each with a remove button unless [onRemove] is null.
class StepTimeline extends StatelessWidget {
  const StepTimeline({
    required this.labels,
    required this.removeTooltip,
    this.onRemove,
    super.key,
  });

  final List<String> labels;
  final String removeTooltip;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    final onRemove = this.onRemove;
    return Column(
      children: [
        for (var index = 0; index < labels.length; index++)
          _StepRow(
            label: labels[index],
            isFirst: index == 0,
            isLast: index == labels.length - 1,
            removeTooltip: removeTooltip,
            onRemove: onRemove == null ? null : () => onRemove(index),
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.label,
    required this.isFirst,
    required this.isLast,
    required this.removeTooltip,
    required this.onRemove,
  });

  static const double _height = 36;

  final String label;
  final bool isFirst;
  final bool isLast;
  final String removeTooltip;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return SizedBox(
      height: _height,
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: _height,
            child: CustomPaint(
              painter: _RailPainter(
                lineColor: colors.border,
                dotColor: colors.accent,
                isFirst: isFirst,
                isLast: isLast,
              ),
            ),
          ),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.accentText,
              ),
            ),
          ),
          if (onRemove != null)
            IconButton(
              onPressed: onRemove,
              tooltip: removeTooltip,
              icon: Icon(Icons.close, size: 18, color: colors.textSecondary),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(
                width: _height,
                height: _height,
              ),
            ),
        ],
      ),
    );
  }
}

/// The dot of a step, joined to the previous and next dots by a line.
class _RailPainter extends CustomPainter {
  const _RailPainter({
    required this.lineColor,
    required this.dotColor,
    required this.isFirst,
    required this.isLast,
  });

  static const double _dotRadius = 5;

  final Color lineColor;
  final Color dotColor;
  final bool isFirst;
  final bool isLast;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final line = Paint()
      ..color = lineColor
      ..strokeWidth = 2;
    if (!isFirst) {
      canvas.drawLine(Offset(center.dx, 0), center, line);
    }
    if (!isLast) {
      canvas.drawLine(center, Offset(center.dx, size.height), line);
    }
    canvas.drawCircle(center, _dotRadius, Paint()..color = dotColor);
  }

  @override
  bool shouldRepaint(_RailPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor ||
      oldDelegate.dotColor != dotColor ||
      oldDelegate.isFirst != isFirst ||
      oldDelegate.isLast != isLast;
}
