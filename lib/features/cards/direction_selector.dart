import 'package:flutter/material.dart';

import '../../app/theme/remanence_colors.dart';
import '../../data/repositories/card_with_directions.dart';
import '../../domain/cards/direction_sense.dart';
import '../../l10n/generated/app_localizations.dart';
import 'card_status_formatter.dart';

/// Two-segment switch between the directions of a card, each with its status
/// and next due date ("cran 4 · ven. 13 nov.").
class DirectionSelector extends StatelessWidget {
  const DirectionSelector({
    required this.card,
    required this.formatter,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final CardWithDirections card;
  final CardStatusFormatter formatter;
  final DirectionSense selected;
  final ValueChanged<DirectionSense> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = RemanenceColors.of(context);
    return Semantics(
      label: AppLocalizations.of(context).cardSheetShownDirection,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colors.segmentBackground,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          spacing: 4,
          children: [
            for (final sense in DirectionSense.values)
              Expanded(child: _segment(context, sense, colors)),
          ],
        ),
      ),
    );
  }

  Widget _segment(
    BuildContext context,
    DirectionSense sense,
    RemanenceColors colors,
  ) {
    final strings = AppLocalizations.of(context);
    final isSelected = sense == selected;
    return Semantics(
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: () => onSelected(sense),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? colors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? const [BoxShadow(color: Color(0x1F0A0A0A), blurRadius: 3)]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 2,
            children: [
              Text(
                switch (sense) {
                  DirectionSense.frontToBack => strings.directionFrontToBack,
                  DirectionSense.backToFront => strings.directionBackToFront,
                },
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? colors.textPrimary : colors.textSecondary,
                ),
              ),
              Text(
                _summary(sense),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _summary(DirectionSense sense) {
    final direction = card.direction(sense);
    if (direction == null) {
      return formatter.strings.cardStatusInactive;
    }
    final status = formatter.directionStatus(card, direction);
    final dueAt = direction.dueAt;
    return direction.isScheduled && dueAt != null
        ? '$status · ${formatter.dueDateLabel(dueAt)}'
        : status;
  }
}
