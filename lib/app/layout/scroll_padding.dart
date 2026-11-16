import 'package:flutter/widgets.dart';

/// Padding of a list that scrolls under the system bars: [padding] plus the
/// system insets left uncovered (navigation bar below, cut-outs on the
/// sides). The list still runs under the navigation bar, but its last
/// element can always be brought above it.
///
/// The insets already consumed above the list (an app bar, a [SafeArea],
/// the tab bar of a [Scaffold]) are 0 in [MediaQuery.paddingOf], so they are
/// not counted twice; with the keyboard open, the bottom inset is 0 too.
EdgeInsets scrollPadding(BuildContext context, EdgeInsets padding) {
  final insets = MediaQuery.paddingOf(context);
  return padding.copyWith(
    left: padding.left + insets.left,
    right: padding.right + insets.right,
    bottom: padding.bottom + insets.bottom,
  );
}
