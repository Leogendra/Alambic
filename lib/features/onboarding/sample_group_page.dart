import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/alambic_colors.dart';
import '../../application/onboarding/onboarding_providers.dart';
import '../../domain/cards/bulk/bulk_card_draft.dart';
import '../../l10n/generated/app_localizations.dart';
import 'onboarding_page.dart';

/// Third screen: the sample group the app creates when the onboarding ends,
/// with its number of cards and its first card. "Start" then opens its page,
/// "Skip" the tabs.
class SampleGroupPage extends ConsumerWidget {
  const SampleGroupPage({
    required this.onStart,
    required this.onSkip,
    super.key,
  });

  final VoidCallback? onStart;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final cards = ref.watch(sampleCardsProvider).value;
    return OnboardingPage(
      title: strings.onboardingSampleTitle,
      body: strings.onboardingSampleBody,
      actions: [
        FilledButton(onPressed: onStart, child: Text(strings.onboardingStart)),
        TextButton(onPressed: onSkip, child: Text(strings.onboardingSkip)),
      ],
      child: cards == null || cards.isEmpty
          ? null
          : _SampleGroupTile(name: strings.sampleGroupName, cards: cards),
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
                Icon(Icons.layers_outlined, color: colors.textSecondary),
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
