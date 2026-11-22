import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'onboarding_page.dart';

/// Second screen: the distillation, the waiting cards of a group let in a
/// few at a time, shown with the sample group once its cards are read.
class DistillationPage extends StatelessWidget {
  const DistillationPage({
    required this.sampleCardCount,
    required this.onNext,
    super.key,
  });

  /// `null` while the cards of the sample group are being read.
  final int? sampleCardCount;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final count = sampleCardCount;
    return OnboardingPage(
      step: 1,
      title: strings.onboardingDistillTitle,
      body: strings.onboardingDistillBody,
      action: FilledButton(
        onPressed: onNext,
        child: Text(strings.onboardingNext),
      ),
      illustration: count == null
          ? null
          : IllustrationCard(
              title: strings.onboardingDistillHeader(count),
              hint: strings.onboardingDistillHint,
              child: _DripLine(count: count),
            ),
    );
  }
}

/// The waiting cards as a pile, then one card a day over a week.
class _DripLine extends StatelessWidget {
  const _DripLine({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    return Row(
      spacing: 12,
      children: [
        Column(
          spacing: 8,
          children: [
            _CardPile(count: count),
          ],
        ),
        Icon(Icons.arrow_forward, size: 20, color: colors.textSecondary),
        const Expanded(child: _Week()),
      ],
    );
  }
}

/// Three cards fanned out, the front one bearing [count].
class _CardPile extends StatelessWidget {
  const _CardPile({required this.count});

  final int count;

  static const double _shift = 4;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    return SizedBox(
      width: 48,
      height: 56,
      child: Stack(
        children: [
          for (var depth = 2; depth >= 0; depth--)
            Positioned(
              left: depth * _shift,
              top: (2 - depth) * _shift,
              child: Container(
                width: 40,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: depth == 0 ? colors.surface : colors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.border),
                ),
                child: depth == 0
                    ? Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}

/// The days of a week from Monday, a dot for the card of each day, on a
/// line.
class _Week extends StatelessWidget {
  const _Week();

  static const double _dotSize = 14;

  @override
  Widget build(BuildContext context) {
    final colors = AlambicColors.of(context);
    // From Sunday.
    final weekdays = MaterialLocalizations.of(context).narrowWeekdays;
    return Stack(
      children: [
        Positioned(
          left: _dotSize,
          right: _dotSize,
          top: (_dotSize - 2) / 2,
          height: 2,
          child: ColoredBox(color: colors.divider),
        ),
        Row(
          children: [
            for (var day = 1; day <= 7; day++)
              Expanded(
                child: Column(
                  spacing: 10,
                  children: [
                    Container(
                      width: _dotSize,
                      height: _dotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.accent,
                      ),
                    ),
                    Text(
                      weekdays[day % 7],
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}
