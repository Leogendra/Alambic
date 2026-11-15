import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'onboarding_page.dart';

/// First screen: the principle of the app in a sentence.
class WelcomePage extends StatelessWidget {
  const WelcomePage({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return OnboardingPage(
      title: strings.onboardingWelcomeTitle,
      body: strings.onboardingWelcomeBody,
      actions: [
        FilledButton(onPressed: onNext, child: Text(strings.onboardingStart)),
      ],
      child: Padding(
        padding: const EdgeInsets.only(top: 32),
        child: Icon(
          Icons.water_drop_outlined,
          size: 96,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
