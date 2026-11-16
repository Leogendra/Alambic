import 'package:flutter/widgets.dart';

/// The main button of a page, anchored under its scrolling content: placed
/// as the last child of the page body, it stays above the system navigation
/// bar, and above the keyboard while one is open since the body of a
/// scaffold then shrinks above it.
class BottomActionArea extends StatelessWidget {
  const BottomActionArea({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.paddingOf(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20 + insets.left,
        12,
        20 + insets.right,
        16 + insets.bottom,
      ),
      child: child,
    );
  }
}
