import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/preferences/interface_settings_providers.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../l10n/generated/app_localizations.dart';
import 'shell/main_shell.dart';
import 'theme/alambic_theme.dart';

/// The app: the welcome screens on the first launch, the tabs afterwards.
class AlambicApp extends ConsumerWidget {
  const AlambicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingDone = ref.watch(
      interfaceSettingsProvider.select((settings) => settings.onboardingDone),
    );
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AlambicTheme.light(),
      darkTheme: AlambicTheme.dark(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: onboardingDone ? const MainShell() : const OnboardingScreen(),
    );
  }
}
