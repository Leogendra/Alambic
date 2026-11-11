import 'package:flutter/material.dart';

import '../theme/remanence_colors.dart';

/// Rounded white panel holding rows separated by thin dividers.
class SurfacePanel extends StatelessWidget {
  const SurfacePanel({
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = RemanenceColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const Divider(height: 1),
            children[index],
          ],
        ],
      ),
    );
  }
}
