import 'package:material_ui/material_ui.dart';

import '../theme/alambic_colors.dart';

/// A group of settings: one rounded block per row, a thin gap between two
/// blocks. Only the outer corners of the group are fully rounded, so the rows
/// still read as one group while each setting stands on its own.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({required this.children, super.key});

  final List<Widget> children;

  static const _outerRadius = Radius.circular(20);
  static const _innerRadius = Radius.circular(6);

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 3,
      children: [
        for (var index = 0; index < children.length; index++)
          Material(
            color: colors.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: index == 0 ? _outerRadius : _innerRadius,
                bottom: index == children.length - 1
                    ? _outerRadius
                    : _innerRadius,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: children[index],
            ),
          ),
      ],
    );
  }
}
