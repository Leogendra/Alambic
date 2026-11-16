import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/preferences/interface_settings_providers.dart';
import '../data/preferences/theme_choice.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../l10n/generated/app_localizations.dart';
import 'app_locale.dart';
import 'shell/main_shell.dart';
import 'theme/alambic_theme.dart';

/// The app: the welcome screens on the first launch, the tabs afterwards, in
/// the language and theme chosen in Settings.
class AlambicApp extends ConsumerWidget {
  const AlambicApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(interfaceSettingsProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AlambicTheme.light(),
      darkTheme: AlambicTheme.dark(),
      themeMode: switch (settings.theme) {
        ThemeChoice.system => ThemeMode.system,
        ThemeChoice.light => ThemeMode.light,
        ThemeChoice.dark => ThemeMode.dark,
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      // The chosen language is read at every build. Following the phone goes
      // through the resolution callback instead, which Flutter runs again
      // when the phone language changes but caches otherwise: it must not
      // depend on the choice.
      locale: AppLocale.chosen(settings.language),
      localeResolutionCallback: (phone, supported) => AppLocale.ofPhone(phone),
      // Screens without an app bar (tabs, session, onboarding) set the style
      // of the system bars through this region.
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: AlambicTheme.systemOverlayStyle(Theme.of(context).brightness),
        child: child!,
      ),
      home: settings.onboardingDone
          ? const MainShell()
          : const OnboardingScreen(),
    );
  }
}
