import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../application/groups/group_providers.dart';
import '../../application/presets/preset_providers.dart';
import '../../domain/cards/card_face.dart';
import '../../domain/cards/card_side.dart';
import '../../domain/cards/flashcard.dart';
import '../../l10n/generated/app_localizations.dart';
import '../cards/card_image.dart';

/// The card of a session, in two halves of fixed height split by a line: the
/// context line and the asked face on top, unchanged by the reveal; the
/// answer below. [reveal] runs from 0 to 1 as the answer shows: the answer
/// fades in while rising. A typed answer gives its [verdict], shown under the
/// answer.
class SessionCardView extends ConsumerWidget {
  const SessionCardView({
    required this.card,
    required this.askedSide,
    required this.reveal,
    required this.isBonus,
    this.verdict,
    super.key,
  });

  final Flashcard card;

  /// Face drawn for this display; the answer is the other one.
  final CardSide askedSide;
  final Animation<double> reveal;
  final bool isBonus;
  final Widget? verdict;

  /// How far the answer rises while it fades in.
  static const _answerRise = 12.0;

  /// Size of the text of a face, never larger: a single word does not fill
  /// the card. A text longer than [_longTextLength] characters is smaller.
  static const maxFontSize = 28.0;
  static const _longTextFontSize = 22.0;
  static const _longTextLength = 60;

  /// Widest the text of a face runs, so that its lines stay readable on a
  /// wide screen.
  static const maxTextWidth = 400.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
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
                    child: _face(card.promptFor(askedSide), colors.textPrimary),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 1, child: ColoredBox(color: colors.divider)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: AnimatedBuilder(
                animation: reveal,
                builder: (context, child) => reveal.value == 0
                    ? const SizedBox.shrink()
                    : Opacity(
                        opacity: reveal.value,
                        child: Transform.translate(
                          offset: Offset(0, _answerRise * (1 - reveal.value)),
                          child: child,
                        ),
                      ),
                child: _answer(colors.textPrimary),
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
        ref
            .watch(presetCatalogProvider)
            .value
            ?.presetForGroup(card.groupId)
            .name ??
        '';
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

  Widget _answer(Color color) {
    final answer = _face(card.answerFor(askedSide), color);
    return switch (verdict) {
      final verdict? => Column(
        spacing: 12,
        children: [
          Expanded(child: answer),
          verdict,
        ],
      ),
      null => answer,
    };
  }

  /// The image of a face above its text, the image shrinking to leave room
  /// for the text. Without an image, a text too long for its half (large
  /// text setting) shrinks to fit it.
  Widget _face(CardFace face, Color color) => SizedBox(
    width: double.infinity,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 12,
      children: [
        if (face.imagePath case final image?) ...[
          Flexible(child: CardImage.stored(image)),
          if (face.hasText) _faceText(face.text!, color),
        ] else if (face.hasText)
          Flexible(child: _fittedFaceText(face.text!, color)),
      ],
    ),
  );

  Widget _fittedFaceText(String text, Color color) => LayoutBuilder(
    builder: (context, constraints) => FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: min(constraints.maxWidth, maxTextWidth),
        child: _faceText(text, color),
      ),
    ),
  );

  /// Already large, the text of a face grows at most this much with the text
  /// size setting, as Android 14 scales large text less than small text.
  static const _maxFaceTextScale = 1.5;

  Widget _faceText(String text, Color color) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: maxTextWidth),
    child: MediaQuery.withClampedTextScaling(
      maxScaleFactor: _maxFaceTextScale,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: text.length > _longTextLength
              ? _longTextFontSize
              : maxFontSize,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: color,
        ),
      ),
    ),
  );
}
