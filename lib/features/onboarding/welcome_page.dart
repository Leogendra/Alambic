import 'package:material_ui/material_ui.dart';

import '../../app/theme/alambic_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'onboarding_page.dart';

/// First screen: the principle of the app, a card coming back at longer and
/// longer intervals.
class WelcomePage extends StatelessWidget {
  const WelcomePage({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return OnboardingPage(
      step: 0,
      title: strings.onboardingWelcomeTitle,
      body: strings.onboardingWelcomeBody,
      action: FilledButton(
        onPressed: onNext,
        child: Text(strings.onboardingNext),
      ),
      illustration: const _RemindersIllustration(),
    );
  }
}

/// "One card, multiple reminders": the reminders of a card on a line, from
/// its start to a month later, and what spaces them out.
class _RemindersIllustration extends StatelessWidget {
  const _RemindersIllustration();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 18,
        children: [
          Text(
            strings.onboardingRemindersTitle.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.8,
              color: colors.textSecondary,
            ),
          ),
          const _ReminderLine(),
          Text(
            strings.onboardingRemindersHint,
            style: TextStyle(fontSize: 14, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// The start of a card and its reminders after 1 day, 2 days, 1 week and 1
/// month, each a dot on a line, its delay under it. The line is not to
/// scale: at a month for its width, the first three dots would merge.
class _ReminderLine extends StatelessWidget {
  const _ReminderLine();

  static const double _dotSize = 14;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = AlambicColors.of(context);
    final stops = [
      (0.0, strings.onboardingRemindersStart),
      (0.13, strings.homeDelayDays(1)),
      (0.24, strings.homeDelayDays(2)),
      (0.45, strings.onboardingRemindersWeek),
      (1.0, strings.onboardingRemindersMonth),
    ];
    return SizedBox(
      height: 56,
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: (_dotSize - 2) / 2,
              height: 2,
              child: ColoredBox(color: colors.divider),
            ),
            for (final (index, (position, label)) in stops.indexed)
              Positioned(
                left:
                    _dotSize / 2 + position * (constraints.maxWidth - _dotSize),
                top: 0,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, 0),
                  child: Column(
                    spacing: 10,
                    children: [
                      Container(
                        width: _dotSize,
                        height: _dotSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == 0
                              ? colors.textSecondary
                              : colors.accent,
                        ),
                      ),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: index == 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: index == 0
                              ? colors.textPrimary
                              : colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
