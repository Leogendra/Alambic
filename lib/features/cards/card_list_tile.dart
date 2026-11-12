import 'package:flutter/material.dart';

import '../../app/theme/alambic_colors.dart';
import '../../data/repositories/card_with_directions.dart';
import 'card_status_formatter.dart';

/// A card in a list: its front, its back with its status, and when it is due.
class CardListTile extends StatelessWidget {
  const CardListTile({
    required this.card,
    required this.formatter,
    required this.onTap,
    super.key,
  });

  final CardWithDirections card;
  final CardStatusFormatter formatter;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    final dueLabel = formatter.dueLabel(card);
    final isDue = dueLabel == formatter.strings.dueNow;
    final back = card.card.backText ?? '';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    card.card.frontText ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$back · ${formatter.status(card)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (dueLabel != null) ...[
              const SizedBox(width: 12),
              Text(
                dueLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDue ? colors.accentText : colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
