import 'package:material_ui/material_ui.dart';

import '../theme/alambic_colors.dart';

/// One tab of [AlambicTabBar].
class TabDestination {
  const TabDestination({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Bottom bar of the root tabs: a surface with a 1 px top border. The
/// active tab is drawn in accent under a 3 px bar across its top, so the
/// selection never rests on the colour alone.
class AlambicTabBar extends StatelessWidget {
  const AlambicTabBar({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  static const double height = 76;

  final List<TabDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: height,
          child: Row(
            children: [
              for (final (index, destination) in destinations.indexed)
                Expanded(
                  child: _tab(
                    destination,
                    index == selectedIndex,
                    index,
                    colors,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(
    TabDestination destination,
    bool isSelected,
    int index,
    AlambicColors colors,
  ) {
    final color = isSelected ? colors.accentText : colors.textSecondary;
    return Semantics(
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: () => onSelected(index),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isSelected ? colors.accentText : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 4,
            children: [
              Icon(destination.icon, size: 22, color: color),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
