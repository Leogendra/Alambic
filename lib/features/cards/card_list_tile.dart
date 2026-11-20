import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../domain/cards/flashcard.dart';
import 'card_image.dart';
import 'card_status_formatter.dart';

/// A card in a list: its front, its back, and where it stands ("in 4 d",
/// "waiting"). A front image shows as a thumbnail; a face without text reads
/// "Image".
class CardListTile extends StatelessWidget {
  const CardListTile({
    required this.card,
    required this.formatter,
    required this.onTap,
    this.mark,
    super.key,
  });

  final Flashcard card;
  final CardStatusFormatter formatter;
  final VoidCallback onTap;

  /// Shown in accent instead of where the card stands, such as "next" for
  /// the head of the queue.
  final String? mark;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    final highlighted = mark != null || formatter.isDue(card);
    final imageOnly = formatter.strings.cardImageOnly;
    final back = card.backText ?? imageOnly;
    final frontImage = card.frontImagePath;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            if (frontImage != null) ...[
              CardImage.stored(
                frontImage,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                radius: 8,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    card.frontText ?? imageOnly,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    back,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              mark ?? formatter.standing(card),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: highlighted ? colors.accentText : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
