import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/alambic_colors.dart';
import '../../application/groups/group_providers.dart';
import '../../application/presets/preset_providers.dart';
import '../../domain/cards/card_face.dart';
import '../../domain/cards/card_side.dart';
import '../../domain/cards/flashcard.dart';
import '../../l10n/generated/app_localizations.dart';
import '../cards/card_image.dart';

/// The card of a session: the prompt on top, the answer below once revealed.
class SessionCardView extends ConsumerWidget {
  const SessionCardView({
    required this.card,
    required this.askedSide,
    required this.isRevealed,
    required this.isBonus,
    super.key,
  });

  final Flashcard card;

  /// Face drawn for this display; the answer is the other one.
  final CardSide askedSide;
  final bool isRevealed;
  final bool isBonus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final prompt = card.promptFor(askedSide);
    final answer = card.answerFor(askedSide);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _context(context, ref, strings),
                  Expanded(
                    child: _face(
                      prompt,
                      isRevealed ? colors.textSecondary : colors.textPrimary,
                      isRevealed ? 30 : 36,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.divider)),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: isRevealed
                  ? _face(answer, colors.textPrimary, 36)
                  : Text(
                      strings.sessionTapToFlip,
                      style: TextStyle(
                        fontSize: 15,
                        color: colors.textSecondary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _context(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations strings,
  ) {
    final colors = AlambicColors.of(context);
    final groupName = ref.watch(groupProvider(card.groupId)).value?.name ?? '';
    final presetName =
        ref.watch(presetCatalogProvider).value?.presetForCard(card).name ?? '';
    final labels = [
      '$groupName · $presetName',
      if (askedSide == CardSide.back) strings.sessionReverseBadge,
      if (isBonus) strings.sessionBonusBadge,
    ];
    return Text(
      labels.join(' · '),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colors.textSecondary,
      ),
    );
  }

  /// The image of a face above its text, the image shrinking to leave room
  /// for the text.
  Widget _face(CardFace face, Color color, double fontSize) => SizedBox(
    width: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 12,
      children: [
        if (face.imagePath case final image?)
          Flexible(child: CardImage.stored(image)),
        if (face.hasText) _faceText(face.text!, color, fontSize),
      ],
    ),
  );

  Widget _faceText(String text, Color color, double fontSize) => Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: text.length > 60 ? fontSize * 0.6 : fontSize,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: color,
    ),
  );
}
