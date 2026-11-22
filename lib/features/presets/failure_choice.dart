import 'package:material_ui/material_ui.dart';

import '../../app/formatting/preset_labels.dart';
import '../../app/widgets/choice_tile.dart';
import '../../domain/presets/failure_behavior.dart';
import '../../l10n/generated/app_localizations.dart';

/// The behaviours on a missed card as a stack of tiles, each with its name and
/// its effect, from the harshest to the gentlest.
class FailureChoice extends StatelessWidget {
  const FailureChoice({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  static const List<FailureBehavior> _order = [
    FailureBehavior.restart,
    FailureBehavior.stepBack,
    FailureBehavior.stay,
  ];

  final FailureBehavior selected;
  final ValueChanged<FailureBehavior> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        for (final behavior in _order)
          ChoiceTile(
            label: strings.failureLabel(behavior),
            detail: strings.failureEffect(behavior),
            isSelected: behavior == selected,
            onTap: () => onSelected(behavior),
          ),
      ],
    );
  }
}
