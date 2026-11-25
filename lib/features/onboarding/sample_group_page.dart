import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../domain/cards/bulk/bulk_card_draft.dart';
import '../../l10n/generated/app_localizations.dart';
import 'onboarding_page.dart';

/// Last screen: the sample group the app creates when the onboarding ends,
/// with its number of cards and its first card. "Get started" then opens
/// its page; "Skip", at the top of the screen, the tabs.
class SampleGroupPage extends StatelessWidget {
  const SampleGroupPage({
    required this.name,
    required this.cards,
    required this.onStart,
    super.key,
  });

  final String name;

  /// `null` while they are being read.
  final List<BulkCardDraft>? cards;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final cards = this.cards;
    return OnboardingPage(
      step: 3,
      title: strings.onboardingSampleTitle,
      body: cards == null ? null : strings.onboardingSampleBody(cards.length),
      action: FilledButton(
        onPressed: onStart,
        child: Text(strings.onboardingGetStarted),
      ),
      illustration: cards == null || cards.isEmpty
          ? null
          : _SampleGroupTile(name: name, cards: cards),
    );
  }
}

/// The name of the group and its number of cards, then its first card.
class _SampleGroupTile extends StatelessWidget {
  const _SampleGroupTile({required this.name, required this.cards});

  final String name;
  final List<BulkCardDraft> cards;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final first = cards.first;
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              spacing: 14,
              children: [
                SizedBox.square(
                  dimension: 44,
                  child: Icon(
                    Icons.layers_outlined,
                    size: 22,
                    color: colors.textTertiary,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        strings.cardCount(cards.length),
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 4,
              children: [
                Text(
                  strings.onboardingSampleFirstCard.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.7,
                    color: colors.textSecondary,
                  ),
                ),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: first.front,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: '  →  ',
                        style: TextStyle(
                          fontSize: 17,
                          color: colors.textSecondary,
                        ),
                      ),
                      TextSpan(
                        text: first.back,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
