import 'package:material_ui/material_ui.dart';

import '../theme/alambic_colors.dart';

/// Rounded white panel holding rows separated by thin dividers.
class SurfacePanel extends StatelessWidget {
  const SurfacePanel({
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.borderColor,
    super.key,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  /// Colour of the outline, to make a panel stand out; the usual border
  /// colour when `null`.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor ?? colors.border,
          width: borderColor == null ? 1 : 1.5,
        ),
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
