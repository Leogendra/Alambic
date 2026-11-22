import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// A scrolling page whose top gives way when pulled down, uncovering
/// [revealed] in the gap: it follows the list, fades in as the pull grows and
/// goes back with it on release. The list bounces on every platform, so the
/// gap exists on Android too.
class PullToReveal extends StatefulWidget {
  const PullToReveal({
    required this.revealed,
    required this.revealedHeight,
    required this.padding,
    required this.children,
    super.key,
  });

  /// What the pull uncovers, laid out at [revealedHeight].
  final Widget revealed;
  final double revealedHeight;
  final EdgeInsetsGeometry padding;
  final List<Widget> children;

  @override
  State<PullToReveal> createState() => _PullToRevealState();
}

class _PullToRevealState extends State<PullToReveal> {
  /// Distance the top of the list is pulled past its start.
  final ValueNotifier<double> _pull = ValueNotifier(0);

  @override
  void dispose() {
    _pull.dispose();
    super.dispose();
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth == 0) {
      final metrics = notification.metrics;
      _pull.value = math.max(0, metrics.minScrollExtent - metrics.pixels);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: ValueListenableBuilder<double>(
          valueListenable: _pull,
          builder: (context, pull, _) => pull == 0
              ? const SizedBox.shrink()
              : SizedBox(
                  height: pull,
                  child: ClipRect(
                    child: Opacity(
                      opacity: (pull / widget.revealedHeight).clamp(0, 1),
                      child: OverflowBox(
                        alignment: Alignment.bottomCenter,
                        minHeight: widget.revealedHeight,
                        maxHeight: widget.revealedHeight,
                        child: widget.revealed,
                      ),
                    ),
                  ),
                ),
        ),
      ),
      NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: widget.padding,
          children: widget.children,
        ),
      ),
    ],
  );
}
