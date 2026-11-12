import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/alambic_colors.dart';
import '../../application/groups/group_providers.dart';
import '../../application/presets/preset_providers.dart';
import '../../data/repositories/card_with_directions.dart';
import '../../domain/cards/card_direction.dart';
import '../../domain/cards/direction_sense.dart';
import '../../l10n/generated/app_localizations.dart';

/// The card of a session: the prompt on top, the answer below once revealed.
class SessionCardView extends ConsumerWidget {
  const SessionCardView({
    required this.card,
    required this.direction,
    required this.isRevealed,
    required this.isBonus,
    super.key,
  });

  final CardWithDirections card;
  final CardDirection direction;
  final bool isRevealed;
  final bool isBonus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final prompt = card.card.promptFor(direction.sense).text ?? '';
    final answer = card.card.answerFor(direction.sense).text ?? '';
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0A0A0A),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
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
                    child: Center(
                      child: _faceText(
                        prompt,
                        isRevealed ? colors.textSecondary : colors.textPrimary,
                        isRevealed ? 30 : 36,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colors.border)),
              ),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(20),
              child: isRevealed
                  ? _faceText(answer, colors.textPrimary, 36)
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
    final groupId = card.card.groupId;
    final groupName = groupId == null
        ? strings.noGroup
        : ref.watch(groupProvider(groupId)).value?.name ?? '';
    final presetName =
        ref.watch(presetCatalogProvider).value?.presetForCard(card.card).name ??
        '';
    final labels = [
      '$groupName · $presetName',
      if (direction.sense == DirectionSense.backToFront)
        strings.sessionReverseBadge,
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
