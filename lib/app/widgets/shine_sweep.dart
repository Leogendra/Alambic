import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

/// Lays a band of light that glides once across [child] when it appears, to
/// catch the eye without moving anything. The band is clipped to
/// [borderRadius], so [child] must be a surface of that shape. Nothing plays
/// when the system asks for no animation.
class ShineSweep extends StatefulWidget {
  const ShineSweep({required this.child, this.borderRadius = 14, super.key});

  final Widget child;
  final double borderRadius;

  @override
  State<ShineSweep> createState() => _ShineSweepState();
}

class _ShineSweepState extends State<ShineSweep>
    with SingleTickerProviderStateMixin {
  /// The pause before the sweep lets the page finish arriving.
  static const _duration = Duration(milliseconds: 1800);
  static const _sweep = Interval(0.3, 1, curve: Curves.easeInOut);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      if (!MediaQuery.disableAnimationsOf(context)) {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _BandPainter(_sweep.transform(_controller.value)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A slanted band of light at [progress] of its way from left to right.
class _BandPainter extends CustomPainter {
  _BandPainter(this.progress);

  static const _bandWidth = 64.0;
  static const _slant = 0.35;

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress > 0 && progress < 1) {
      final skew = size.height * _slant;
      final travel = size.width + _bandWidth + skew;
      final left = -_bandWidth - skew + travel * progress;
      final band = Path()
        ..moveTo(left + skew, 0)
        ..lineTo(left + skew + _bandWidth, 0)
        ..lineTo(left + _bandWidth, size.height)
        ..lineTo(left, size.height)
        ..close();
      const light = Color(0x4DFFFFFF);
      final paint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(left, 0),
          Offset(left + _bandWidth + skew, 0),
          [light.withValues(alpha: 0), light, light.withValues(alpha: 0)],
          const [0, 0.5, 1],
        );
      canvas.drawPath(band, paint);
    }
  }

  @override
  bool shouldRepaint(_BandPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
